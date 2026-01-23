#!/bin/sh

DEBIAN_SUITE=$1
SUITE=$2

# Add debian-security for stable releases; note that only the main component is supported
if [ "${DEBIAN_SUITE}" = "bullseye" ] || [ "${DEBIAN_SUITE}" = "bookworm" ] || [ "${DEBIAN_SUITE}" = "trixie" ]; then
    echo "deb http://security.debian.org/ ${DEBIAN_SUITE}-security main" >> /etc/apt/sources.list
fi

# Set the proper suite in our sources file
sed -i "s/Suites: .*/Suites: ${SUITE}/" /etc/apt/sources.list.d/mobian.sources

# Setup repo priorities so mobian comes first
cat > /etc/apt/preferences.d/00-mobian-priority << EOF
Package: *
Pin: release o=Mobian
Pin-Priority: 700
EOF
