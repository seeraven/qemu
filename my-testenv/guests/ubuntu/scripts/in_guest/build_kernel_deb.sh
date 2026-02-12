#!/bin/bash
#
# Run inside guest as root!
#
set -e

cd linux-*

cp ../annotations-* debian.master/config/annotations

if ! grep -q "+cma" debian/changelog; then
    awk 'NR==1,/\)/{sub(/\)/, "+cma\)")} 1' debian/changelog > debian/changelog.new
    mv debian/changelog.new debian/changelog
fi

fakeroot debian/rules binary-headers binary-generic binary-perarch
