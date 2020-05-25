#!/usr/bin/env bash
set -eu

VERSION=${1}

# Make sure we operate with the repository directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


if [[ ! "$VERSION" ]]; then
  echo "download.sh: No version issued for download!"
  echo "Usage:"
  echo "  ./download.sh <version>"
  echo "Example:"
  echo "  ./download.sh 2.0.0"
  exit 1
fi

RUNTIME_URI="https://github.com/ndsev/zserio/releases/download/v$VERSION/zserio-$VERSION-runtime-libs.zip"
JAR_URI="https://github.com/ndsev/zserio/releases/download/v$VERSION/zserio-$VERSION-bin.zip"

mkdir -p "$DIR/cache/$VERSION"
cd "$DIR/cache/$VERSION"

curl -s -L "$RUNTIME_URI" > runtime.zip
curl -s -L "$JAR_URI" > jar.zip
