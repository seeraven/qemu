#!/bin/bash
#
# Install all necessary tools required to build a custom kernel.
#
set -e

# Arguments
TGTIMG="$1"

# Settings
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
SSH_KEY_DIR=$(readlink -f "${SCRIPT_DIR}/../../ssh_keys")

# ssh command
SSH_CMD="ssh -p 2242 -i ${SSH_KEY_DIR}/qemu -o StrictHostKeychecking=no -o UserKnownHostsFile=/dev/null root@localhost"
SCP_CMD="scp -P 2242 -i ${SSH_KEY_DIR}/qemu -o StrictHostKeychecking=no -o UserKnownHostsFile=/dev/null"

# Ensure we remove the target image file on errors
err_handler() {
    echo "ERROR DETECTED. DELETING $TGTIMG."
    rm -f "$TGTIMG"
    exit 1
}
trap 'err_handler' ERR

# Start the qemu
