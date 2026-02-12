#!/bin/bash
#
# Run inside guest as root!
#

# Enable source packages
if [ $(lsb_release -r -s) == "24.04" ]; then
    sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
else
    sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list
fi

# Update the system
apt update
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
