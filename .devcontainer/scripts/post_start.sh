#!/bin/bash
#
# Script executed within the devcontainer to finalize the startup.
#
SCRIPT_DIR=$(dirname $(readlink -f $0))
REPO_BASE_DIR=$(dirname $(dirname $SCRIPT_DIR))

OUTER_HOME=$1

# Determine current user information
[ -z "$USER" ] && USER=$(whoami)
[ -z "$UID" ] && UID=$(id -u)
[ -z "$GID" ] && GID=$(id -g)

echo
echo "User in devcontainer:    $USER (uid: $UID, gid: $GID)"
echo "Home directory (docker): $HOME"
echo "Home directory (host):   $OUTER_HOME"
echo "Repository base dir:     $REPO_BASE_DIR"
echo

echo "Adjust permissions of mounted volumes..."
sudo chown -R $UID:$GID /bash_history
sudo chown -R $UID:$GID $HOME/.ccache

# We do a mknod for /dev/kvm/ to start sudo-less KVM acceleration with qemu
if [ ! -c "/dev/kvm" ]; then
  echo "Create /dev/kvm node..."
  sudo mknod /dev/kvm c 10 $(grep '\<kvm\>' /proc/misc | cut -f 1 -d' ')
fi
echo "Adjusting permissions on the /dev/kvm node"
sudo chown $UID:$GID /dev/kvm

echo "All done"

cat << EOF

To build qemu for x86, execute the following commands:

    mkdir build
    cd build
    ../configure --target-list=x86_64-softmmu,x86_64-linux-user
    make -j

EOF