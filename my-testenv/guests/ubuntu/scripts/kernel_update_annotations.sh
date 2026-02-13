#!/bin/bash
#
# Update the annotations file.
#
set -e

# Arguments
QEMUIMG="$1"
ANNOTATIONSDIR="$2"

# Settings
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
SSH_KEY_DIR=$(readlink -f "${SCRIPT_DIR}/../../ssh_keys")
PRIVATE_KEY=${SSH_KEY_DIR}/qemu

SSH="ssh -p 2242 -i ${PRIVATE_KEY} -o StrictHostKeychecking=no -o UserKnownHostsFile=/dev/null root@localhost"
SCP="scp -P 2242 -i ${PRIVATE_KEY} -o StrictHostKeychecking=no -o UserKnownHostsFile=/dev/null"

# Ensure we remove the target image file on errors
err_handler() {
    echo "ERROR DETECTED. SHUTTING DOWN QEMU."
    $SSH poweroff
    exit 1
}
trap 'err_handler' ERR

# Start the qemu
qemu-system-x86_64 -m 8G \
	  -smp 16 \
	  -enable-kvm \
      -drive if=virtio,file=$QEMUIMG,cache=none \
      -net user,hostfwd=tcp::2242-:22 -net nic -nographic \
      &> /dev/null &
QEMU_PID=$!

echo "Waiting for the machine to start in the background..."
STARTTIME=$(date +%s)
while ! $SSH true; do
    CURRENTTIME=$(date +%s)
    TIMEDIFF=$(($CURRENTTIME-$STARTTIME))
    echo " +${TIMEDIFF}: Sleeping for 10s before next attempt."
    sleep 10s
done
echo "Connected!"

echo "Copy build files and scripts..."
$SCP ${SCRIPT_DIR}/in_guest/kernel_update_annotations.sh root@localhost:

echo "Executing script in qemu guest..."
$SSH ./kernel_update_annotations.sh

echo "Copying annotations back to host..."
mkdir -p "${ANNOTATIONSDIR}"
$SCP root@localhost:annotations-* "${ANNOTATIONSDIR}/"

echo "Power off the qemu machine..."
$SSH poweroff || true

echo "Waiting for shutdown of qemu virtual machine..."
wait $QEMU_PID

echo "qemu virtual machine has stopped."
