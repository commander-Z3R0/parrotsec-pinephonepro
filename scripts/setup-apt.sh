#!/bin/sh
MOBIAN_SUITE="trixie"   
PARROT_SUITE="echo"        

# Parrot (suite echo)
cat > /etc/apt/sources.list.d/parrot.list << EOF
deb https://deb.parrot.sh/parrot ${PARROT_SUITE} main contrib non-free non-free-firmware
EOF

# Mobian (suite trixie)
cat > /etc/apt/sources.list.d/mobian.sources << EOF
Types: deb
URIs: https://repo.mobian.org/debian
Suites: ${MOBIAN_SUITE}
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
