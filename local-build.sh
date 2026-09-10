#!/usr/bin/env bash
set -eu

VERSION=${1?please specify a gemstone version. $0 6.7.2.1 for example}
# Take the first two components only: 6.7.2.1 -> 67. A greedy match here
# yields 6.72 for four-component versions and breaks the comparison below.
MAJOR=$(sed -r 's/^([0-9]+)\.([0-9]+).*$/\1\2/' <<< "$VERSION")
if (( MAJOR < 67 ))
then ARCH=i686
else ARCH=x86_64
fi

docker build \
  --cache-from "gemstone:base" \
  --file "Dockerfile" \
  --tag "gemstone:base" \
  --target base \
  .
docker build \
  --build-arg "GS_ARCH=$ARCH" \
  --build-arg "GS_MAJOR_VERSION=$MAJOR" \
  --build-arg "GS_VERSION=$VERSION" \
  --cache-from "gemstone:base" \
  --cache-from "gemstone:$VERSION" \
  --file "Dockerfile" \
  --tag "gemstone:$VERSION" \
  .
