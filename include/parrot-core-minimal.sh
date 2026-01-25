#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "[*] Installing Parrot archive keyring"
wget -q https://deb.parrot.sh/parrot/pool/main/p/parrot-archive-keyring/parrot-archive-keyring_2024.12_all.deb
apt install -y ./parrot-archive-keyring_2024.12_all.deb
rm -f parrot-archive-keyring_2024.12_all.deb

echo "[*] Installing Parrot APT configuration"
cp /opt/parrot-config/etc/apt/sources.list /etc/apt/sources.list
cp -r /opt/parrot-config/etc/apt/sources.list.d/* /etc/apt/sources.list.d/
cp /opt/parrot-config/etc/apt/listchanges.conf /etc/apt/listchanges.conf

echo "[*] Updating package lists"
apt update

echo "[*] Installing parrot-core"
apt install -y parrot-core

echo "[✓] Parrot Core installation completed"
