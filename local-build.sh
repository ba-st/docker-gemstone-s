#!/bin/bash
set -eu

VERSION=${1?please specify a gemstone version. $0 6.6.5 for example}
MAJOR=$(sed -r 's/^(.*)\.(.*)\..*$/\1\2/' <<< "$VERSION")
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
