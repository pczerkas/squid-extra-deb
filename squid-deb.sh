#!/bin/bash
set -eu -o pipefail

DISTRO=$1
RELEASE=$2
TARGET_SQUID_VERSION=$3
NEW_SQUID_VERSION=$4
PRIVATE_GPG_KEY=$5
PRIVATE_GPG_KEY_PASSPHRASE=$6

error() {
  echo 2>&1 "$1"
  exit 1
}

dir="__build/squid-$DISTRO-$RELEASE"

[[ -d "$dir" ]] && rm -r "$dir"
mkdir -p "$dir"
pushd "$dir"

#pull-lp-source squid "$release" 2>&1
pull-debian-source --arch=amd64 squid "$TARGET_SQUID_VERSION" 2>&1
pushd "$(find squid* -maxdepth 0 -type d)"

# shellcheck disable=SC2016
patch -p0 < "../../../patches/$DISTRO-$RELEASE/squid-$TARGET_SQUID_VERSION/debian.patch" \
  || (echo "PATCHES REJECTED !!!" && find . -name "*.rej" -exec cat {} \; -exec bash -c 'cat "${0%%.rej}"' {} \; && exit 1)

# shellcheck disable=SC1091
. /opt/bin/install-build-dependencies.sh

# shellcheck disable=SC1091
. /opt/bin/insert-source-patches.sh
# for debugging
#ls debian/patches
#cat debian/patches/series
#exit 1

header="$(head -1 debian/changelog | sed -E "s/\(([[:alnum:]:.~-]+)\) [[:alnum:]:.~-]+\;/($NEW_SQUID_VERSION+extra) $RELEASE\;/; t; q1")" || error "Malformed header"
cat > debian/changelog~ << END
$header

  * Build with extra options in refresh_pattern

 -- Przemek Czerkas <pczerkas@gmail.com>  $(date -R)

$(cat debian/changelog)
END
mv debian/changelog~ debian/changelog
head debian/changelog

echo "$PRIVATE_GPG_KEY" | gpg --import -a --no-tty --batch --yes

## build binary
# debuild --no-lintian -S -d -- binary

## build source
# don't include original source in package:
##debuild --no-lintian -S -sd -p"gpg --batch --passphrase $PRIVATE_GPG_KEY_PASSPHRASE --pinentry-mode loopback"

# include original source in package:
debuild --no-lintian -S -sa -p"gpg --batch --passphrase $PRIVATE_GPG_KEY_PASSPHRASE --pinentry-mode loopback"

## push ppa to launchpad
dput -f ppa:pczerkas/squid-extra ../squid*+extra_source.changes 2>&1

popd
popd
