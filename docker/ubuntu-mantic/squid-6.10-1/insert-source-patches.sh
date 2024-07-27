#!/bin/bash
set -eu -o pipefail

cp ../../../patches/"$DISTRO"-"$RELEASE"/squid-"$TARGET_SQUID_VERSION"/squid-extra.patch debian/patches/1000-squid-extra.patch
echo "1000-squid-extra.patch" >> debian/patches/series
patch -t -F 0 -N -p1 -u -V never -E -b --reject-file=squid-extra.patch.rej < "../../../patches/$DISTRO-$RELEASE/squid-$TARGET_SQUID_VERSION/squid-extra.patch" \
    || (echo "PATCHES REJECTED !!!" && cat squid-extra.patch.rej && exit 1)

cp ../../../patches/"$DISTRO"-"$RELEASE"/squid-"$TARGET_SQUID_VERSION"/BoolOps.cc.patch debian/patches/1001-BoolOps.cc.patch
echo "1001-BoolOps.cc.patch" >> debian/patches/series
patch -t -F 0 -N -p1 -u -V never -E -b --reject-file=BoolOps.cc.patch.rej < "../../../patches/$DISTRO-$RELEASE/squid-$TARGET_SQUID_VERSION/BoolOps.cc.patch" \
    || (echo "PATCHES REJECTED !!!" && cat BoolOps.cc.patch.rej && exit 1)
