#!/bin/bash
set -e

PASSWORD="${1}"
BOOTONROOT="${2}"

# ROOTDIR must be provided by debos
: "${ROOTDIR:?ROOTDIR is not set}"

PART=""
PARTNR=2

echo "[+] Detecting target disk"

# Prefer virtio disk if present (fakemachine/qemu)
if [ -b /dev/vda ]; then
    TARGET_DISK=/dev/vda
else
    # Fallback: detect disk owning the mounted /boot partition
    TARGET_DISK="$(lsblk -n -o PKNAME,MOUNTPOINT | awk '$2=="/boot"{print "/dev/"$1; exit}')"
fi

if [ -z "${TARGET_DISK}" ] || [ ! -b "${TARGET_DISK}" ]; then
    echo "ERROR: Unable to detect target disk"
    exit 1
fi

echo "[+] Using target disk: ${TARGET_DISK}"

# Unmount root (and boot if separate) before encryption
if [ "${BOOTONROOT}" != "true" ]; then
    umount -lf "${ROOTDIR}/boot" || true
    umount -lf "${ROOTDIR}"
else
    umount -lf "${ROOTDIR}"
    PARTNR=1
fi

# Handle devices using pX partition naming (e.g. mmcblk0p2)
if [[ "${TARGET_DISK}" =~ [0-9]$ ]]; then
    PART="p"
fi

ROOT_PART="${TARGET_DISK}${PART}${PARTNR}"

echo "[+] Root partition: ${ROOT_PART}"

FILESYSTEM="$(blkid -s TYPE -o value "${ROOT_PART}")"

if [ -z "${FILESYSTEM}" ]; then
    echo "ERROR: Unable to detect filesystem type"
    exit 1
fi

# Shrink filesystem to make room for LUKS metadata
if [ "${FILESYSTEM}" = "ext4" ]; then
    echo "[+] Minimizing ext4 filesystem before encryption"
    resize2fs -fM "${ROOT_PART}"
fi

echo "[+] Encrypting root filesystem with LUKS2"

# Re-encrypt in-place to avoid repartitioning
echo "${PASSWORD}" | cryptsetup reencrypt "${ROOT_PART}" root \
  --new \
  --reduce-device-size 32M \
  --type luks2 \
  --cipher aes-xts-essiv:sha256 \
  --key-size 512 \
  --hash sha512 \
  --pbkdf argon2id \
  --pbkdf-memory 262144 \
  --pbkdf-parallel 2 \
  --iter-time 2000

echo "[+] Resizing filesystem after encryption"

# Grow filesystem to fill the encrypted mapping
case "${FILESYSTEM}" in
    ext4)
        resize2fs -f /dev/mapper/root
        ;;
    f2fs)
        resize.f2fs -s /dev/mapper/root
        ;;
    btrfs)
        btrfs filesystem resize max /dev/mapper/root
        ;;
esac

echo "[+] Remounting root filesystem"

mount /dev/mapper/root "${ROOTDIR}"

if [ "${BOOTONROOT}" != "true" ]; then
    mount "${TARGET_DISK}${PART}1" "${ROOTDIR}/boot"
fi

# Retrieve UUID of the encrypted container
rootfs_uuid="$(blkid -s UUID -o value "${ROOT_PART}")"

echo "[+] Writing fstab"

cat > "${ROOTDIR}/etc/fstab" <<EOF
/dev/mapper/root  /  ${FILESYSTEM}  defaults,noatime,x-systemd.growfs  0  1
EOF

if [ "${BOOTONROOT}" != "true" ]; then
cat >> "${ROOTDIR}/etc/fstab" <<EOF
LABEL=boot  /boot  ext4  defaults,noatime,x-systemd.growfs  0  1
EOF
fi

echo "[+] Writing crypttab"

# unl0kr keyscript enables passphrase entry on mobile devices
cat > "${ROOTDIR}/etc/crypttab" <<EOF
root UUID=${rootfs_uuid} none luks,keyscript=/usr/share/initramfs-tools/scripts/unl0kr-keyscript
EOF

echo "[+] LUKS setup completed successfully"
