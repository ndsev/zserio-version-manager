#!/usr/bin/env bash
set -e

VERSION=${1}

if [[ ! "$VERSION" ]]; then
  echo "set-version.sh: Invalid argument(s)!"
  echo "Usage:"
  echo "  ./set-version.sh <version>"
  echo "Example:"
  echo "  ./set-version.sh 2.0.0"
  exit 1
fi

RUNTIME_ZIP="cache/$VERSION/runtime.zip"
JAR_ZIP="cache/$VERSION/jar.zip"

# Make sure desired version is retrieved
if [[ ! -f "$RUNTIME_ZIP" || ! -f "$JAR_ZIP" ]]; then
  ./download.sh "$VERSION"
fi

# Cleanup previous version
rm -f current/zserio/*.py
rm -f current/zserio/*.rej
rm -f current/zserio/zserio.jar
rm -rf current/zserio/jar
rm -rf current/zserio/runtime

# Install relevant files from ZIP...
unzip "$RUNTIME_ZIP" -d "current/zserio/runtime"
unzip "$JAR_ZIP" -d "current/zserio/jar"
cp current/zserio/jar/zserio.jar current/zserio/zserio.jar
mv current/zserio/runtime/runtime_libs/* current/zserio/runtime
cp current/zserio/runtime/python/zserio/*.py current/zserio
cp patch/gen.py current/zserio
patch current/zserio/__init__.py patch/gen.patch
rm -f current/zserio/*.orig

# Extract version
ZSERIO_VERSION=$(java -jar current/zserio/zserio.jar -version | sed "s/version //g")
echo "$ZSERIO_VERSION" > current-version.txt
echo "Zserio version set to $ZSERIO_VERSION."
