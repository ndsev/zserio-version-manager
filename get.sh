#!/usr/bin/env bash

# Make sure we operate with the repository directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Make sure that the first argument looks like a version
VERSION=""
DESTINATION="$DIR/current/zserio"
WITH_PYTHON=false

for arg in "$@"; do
  case $arg in
  --python-module|-p)
    WITH_PYTHON=true
    shift
    ;;
  --version|-v)
    VERSION=$(echo "$2" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+(\\-pre[0-9]?)?$")
    shift
    shift
    ;;
  --directory|-d)
    DESTINATION=$2
    shift
    shift
    ;;
  esac
done

set -e
if [[ "$VERSION" == "" ]]; then
  echo "get.sh: Invalid argument(s)!"
  echo ""
  echo "Usage:"
  echo "  ./get.sh [--python-module|-p] [--version|-v <version>] [--directory|-d <path>]"
  echo ""
  echo "Description:"
  echo "  Get zserio version artifacts for a specific version. The artifacts"
  echo "  are unpacked to (destination) in the following layout:"
  echo "   DESTINATION/"
  echo "   | runtime/"
  echo "   | | cpp/..."
  echo "   | | java/..."
  echo "   | | python/..."
  echo "   | zserio.jar"
  echo "   | version.txt"
  echo "   | [if --python-module: zserio runtime python sources]"
  echo ""
  echo "Args:"
  echo "  version: Desired zserio version (see https://github.com/ndsev/zserio/releases)"
  echo "  directory: (Optional) Target path where the respective artifacts should be placed."
  echo "   Note: By default, the destination is set to current/zserio"
  echo "  python-module: Prepare the target folder such that it contains a zserio runtime"
  echo "   python module that also supports the zserio.generate() function."
  echo ""
  echo "Example:"
  echo "  ./get.sh -p -v 2.0.0"
  exit 1
fi

RUNTIME_ZIP="$DIR/cache/$VERSION/runtime.zip"
JAR_ZIP="$DIR/cache/$VERSION/jar.zip"

# Make sure desired version is retrieved
if [[ ! -f "$RUNTIME_ZIP" || ! -f "$JAR_ZIP" ]]; then
  "$DIR/download.sh" "$VERSION"
fi

# Cleanup previous version
rm -f "$DESTINATION"/*.py
rm -f "$DESTINATION"/*.rej
rm -f "$DESTINATION"/*.orig
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
if [[ $WITH_PYTHON == "true" ]]; then
    cp "$DESTINATION"/runtime/python/zserio/*.py "$DESTINATION"
    cp "$DIR/patch/gen.py" "$DESTINATION"
    patch "$DESTINATION/__init__.py" "$DIR/patch/gen.patch"
    rm -f "$DESTINATION"/*.orig
fi
rm -rf "$DESTINATION"/jar

# Extract version
ZSERIO_VERSION=$(java -jar "$DESTINATION/zserio.jar" -version | sed "s/version //g")
echo "$ZSERIO_VERSION" > "$DESTINATION/version.txt"
echo "Zserio version at $DESTINATION is now $ZSERIO_VERSION."
