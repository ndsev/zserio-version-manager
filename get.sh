#!/usr/bin/env bash

# Make sure that the first argument looks like a version
VERSION=$(echo "$1" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+(\\-pre[0-9]?)?$")
DESTINATION=${2:-current/zserio}

set -e
if [[ "$VERSION" == "" ]]; then
  echo "get.sh: Invalid argument(s)!"
  echo ""
  echo "Usage:"
  echo "  ./get.sh <version> [<destination>]"
  echo ""
  echo "Description:"
  echo "  Get zserio version artifacts for a specific version. The artifacts"
  echo "  are unpacked to (destination) in the following layout:"
  echo "   DESTINATION/"
  echo "   | runtime/"
  echo "   | | cpp/..."
  echo "   | | java/..."
  echo "   | | python/..."
  echo "   | __init__.py"
  echo "   | (zserio runtime python sources...)"
  echo "   | zserio.jar"
  echo "   | version.txt"
  echo ""
  echo "Args:"
  echo "  version: Desired zserio version (see https://github.com/ndsev/zserio/releases)"
  echo "  destination: (Optional) Target path where the respective artifacts should be placed."
  echo "   Note: By default, the destination is set to current/zserio"
  echo ""
  echo "Example:"
  echo "  ./get.sh 2.0.0"
  exit 1
fi

RUNTIME_ZIP="cache/$VERSION/runtime.zip"
JAR_ZIP="cache/$VERSION/jar.zip"

# Make sure desired version is retrieved
if [[ ! -f "$RUNTIME_ZIP" || ! -f "$JAR_ZIP" ]]; then
  ./download.sh "$VERSION"
fi

# Cleanup previous version
rm -f "$DESTINATION"/*.py
rm -f "$DESTINATION"/*.rej
rm -f "$DESTINATION"/zserio.jar
rm -f "$DESTINATION"/version.txt
rm -rf "$DESTINATION"/jar
rm -rf "$DESTINATION"/runtime

# Install relevant files from ZIP...
mkdir -p "$DESTINATION"
unzip -q "$RUNTIME_ZIP" -d "$DESTINATION/runtime"
unzip -q "$JAR_ZIP" -d "$DESTINATION/jar"
cp "$DESTINATION/jar/zserio.jar" "$DESTINATION/zserio.jar"
mv "$DESTINATION"/runtime/runtime_libs/* "$DESTINATION/runtime"
cp "$DESTINATION"/runtime/python/zserio/*.py "$DESTINATION"
cp patch/gen.py "$DESTINATION"
patch "$DESTINATION/__init__.py" patch/gen.patch
rm -f "$DESTINATION"/*.orig

# Extract version
ZSERIO_VERSION=$(java -jar "$DESTINATION/zserio.jar" -version | sed "s/version //g")
echo "$ZSERIO_VERSION" > "$DESTINATION/version.txt"
echo "Zserio version at $DESTINATION is now $ZSERIO_VERSION."
