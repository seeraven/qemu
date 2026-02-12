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

# Update the apt indices
apt update

# Install dependencies
apt install -y build-essential
apt build-dep -y linux linux-image-unsigned-$(uname -r)
apt install -y libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf llvm

# Install and prepare the kernel source package
apt source linux-image-unsigned-$(uname -r)

cd linux-*
chmod a+x debian/rules
chmod a+x debian/scripts/*
chmod a+x debian/scripts/misc/*
fakeroot debian/rules clean
