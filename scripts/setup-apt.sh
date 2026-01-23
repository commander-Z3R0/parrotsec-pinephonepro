#!/bin/sh
DEBIAN_SUITE=forky
SUITE=$2

# Parrot repos (prioridad 700)
cat > /etc/apt/sources.list.d/parrot.list << EOF
deb https://deb.parrot.sh/parrot ${SUITE} main contrib non-free non-free-firmware
EOF

# Mobian repos (priority 600 - Parrot)
cat > /etc/apt/sources.list.d/mobian.sources << EOF
Types: deb
URIs: https://repo.mobian.org/debian
Suites: ${DEBIAN_SUITE}
Components: main
Signed-By: /usr/share/keyrings/mobian-archive-keyring.gpg
EOF

# Priority: Parrot > Mobian
cat > /etc/apt/preferences.d/99-parrot-priority << EOF
Package: *
Pin: origin deb.parrot.sh
Pin-Priority: 700

Package: *
Pin: origin repo.mobian.org  
Pin-Priority: 600
EOF
