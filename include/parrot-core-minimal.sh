#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "[+] Blocking service startup"
cat << 'EOF' > /usr/sbin/policy-rc.d
#!/bin/sh
exit 101
EOF
chmod +x /usr/sbin/policy-rc.d

echo "[+] Installing Parrot keyring"
wget -q https://deb.parrot.sh/parrot/pool/main/p/parrot-archive-keyring/parrot-archive-keyring_2024.12_all.deb
apt-get install -y ./parrot-archive-keyring_2024.12_all.deb

echo "[+] Adding Parrot repository"
echo "deb https://deb.parrot.sh/parrot rolling main" > /etc/apt/sources.list.d/parrot.list

echo "[+] Installing Parrot core"
apt-get update
apt-mark hold apparmor apparmor-profiles apparmor-profiles-extra || true
apt-get install -y parrot-core || true

echo "[+] Fixing dpkg"
dpkg --configure -a || true
apt-get -f install -y || true

echo "[+] Done"
