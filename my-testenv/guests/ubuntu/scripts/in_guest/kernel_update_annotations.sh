#!/bin/bash
#
# Run inside guest as root!
#
set -e

rm -f annotations-*

cd linux-*

echo "Export annotations..."
debian/scripts/misc/annotations --arch amd64 --flavour generic --export > config
cat >> config <<EOF
CONFIG_CMA=y
CONFIG_CMA_SIZE_MBYTES=32
CONFIG_DMA_CMA=y
CONFIG_CMA_ALIGNMENT=8
CONFIG_CMA_AREAS=19
CONFIG_CMA_DEBUG=n
CONFIG_CMA_DEBUGFS=y
CONFIG_CMA_SIZE_SEL_MAX=n
CONFIG_CMA_SIZE_SEL_MBYTES=y
CONFIG_CMA_SIZE_SEL_MIN=n
CONFIG_CMA_SIZE_SEL_PERCENTAGE=n
CONFIG_CMA_SYSFS=y
EOF

echo "Import annotations..."
debian/scripts/misc/annotations --arch amd64 --flavour generic --import config

echo "Update configurations..."
fakeroot debian/rules clean updateconfigs

echo "Copy updated annotations file to annotations-$(uname -r)..."
cp debian.master/config/annotations ../annotations-$(uname -r)
