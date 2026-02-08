#!/bin/bash
#
# Create the base image from a downloaded cloud image.
#
set -e

TGTIMG="$1"
SRCIMG="$2"
TMPIMG="$3"

# Ensure we remove the target image file on errors
err_handler() {
    echo "ERROR DETECTED. DELETING $TGTIMG."
    rm -f "$TGTIMG"
    exit 1
}
trap 'err_handler' ERR


echo "Building $TGTIMG from $SRCIMG using temporary image $TMPIMG"

rm -f "$TMPIMG"

echo "Increase image size by 32GB..."
cp "$SRCIMG" "$TMPIMG"
qemu-img resize "$TMPIMG" +32G
cp "$TMPIMG" "$TMPIMG.bak"
sudo virt-resize --expand /dev/sda1 "$TMPIMG.bak" "$TMPIMG"
rm -f "$TMPIMG.bak"
sudo virt-customize -a "$TMPIMG" --run-command 'grub-install /dev/sda'

echo "Customizing image..."
TMPNETWORK=$(mktemp)
echo -e "[Match]\nName=ens3\n[Network]\nDHCP=ipv4\nLinkLocalAddressing=no\n" > $TMPNETWORK
sudo chmod 644 $TMPNETWORK
sudo chown root:root $TMPNETWORK
sudo virt-customize -a "$TMPIMG"                                                                        \
                    --root-password password:root                                                       \
                    --upload $TMPNETWORK:/etc/systemd/network/ens3.network                              \
                    --delete /etc/ssh/sshd_config.d/60-cloudimg-settings.conf                           \
                    --append-line '/etc/ssh/sshd_config.d/50-allow-root-login.conf:PermitRootLogin yes' \
                    --append-line '/etc/cloud/cloud-init.disabled:disabled'                             \
                    --run-command 'ssh-keygen -A'                                                       \
                    --ssh-inject root:file:../ssh_keys/qemu.pub
sudo rm -f $TMPNETWORK

echo "Creating compressed image $TGTIMG ..."
qemu-img convert -O qcow2 -c "$TMPIMG" "$TGTIMG"
rm -f "$TMPIMG"
