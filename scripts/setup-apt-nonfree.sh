#!/bin/sh

NONFREE=$1

if [ "${NONFREE}" != "true" ]; then
    exit 0
fi

COMPONENTS="main non-free-firmware"

# Enable non-free-firmware for both the Debian and Mobian sources
sed -i 's/main$/main non-free-firmware/g' /etc/apt/sources.list
sed -i 's/main$/main non-free-firmware/g' /etc/apt/sources.list.d/mobian.sources
