#!/bin/bash
set -eu -o pipefail

mk-build-deps --tool 'apt-get -y -o Debug::pkgProblemResolver=yes --no-install-recommends' --install debian/control \
    || (echo "mk-build-deps FAILED !!!" && apt --fix-broken install && exit 1)

rm squid-build-deps*
