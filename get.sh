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
  --cache|-z)
    CACHE_DIR=$2
    shift
    shift
    ;;
  --quick|-q)
    QUICK_REQUESTED=true
    shift
    ;;
  esac
done

set -e
if [[ "$VERSION" == "" ]]; then
  echo "get.sh: Invalid argument(s)!"
  echo ""
  echo "Usage:"
  echo "  ./get.sh [--quick] [--python-module|-p] [--version|-v <version>] [--directory|-d <path>] [--cache|-c <cache-dir>]"
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
  echo "  cache: (Optional) Path to look up and store unzipped Zserio artifacts."
  echo "  quick: (Optional) Skip processing if current zserio version in destination matches the required."
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

if [[ -f "$DESTINATION"/version.txt ]]; then
  PREV_VERSION=`cat "$DESTINATION"/version.txt`
fi

if [[ $QUICK_REQUESTED == "true" ]]; then
  if [[ "$PREV_VERSION" == "$VERSION" ]]; then
    echo "Quick mode: re-using zserio artifact v${VERSION} from previous run."
    exit 0
  else
    echo "Changing zserio version of package: ${PREV_VERSION} -> ${VERSION}"
  fi
fi

# Cleanup previous zserio artifacts if these were at another version
if [[ -z "$PREV_VERSION" || ! "$PREV_VERSION" == "$VERSION" ]]; then
  # TODO alternative to throwing out all .py files? Seems dangerous...
  rm -f "$DESTINATION"/*.py
  rm -f "$DESTINATION"/*.rej
  rm -f "$DESTINATION"/*.orig
  rm -f "$DESTINATION"/zserio.jar
  rm -f "$DESTINATION"/version.txt
  rm -rf "$DESTINATION"/jar
  rm -rf "$DESTINATION"/runtime
fi

mkdir -p "$DESTINATION"
mkdir -p "$DESTINATION/runtime"

# Setup cache if needed
if [[ -n "${CACHE_DIR}" ]]; then
  SOURCE="$CACHE_DIR/$VERSION"
  mkdir -p "$SOURCE"
else
  # Unzip to a temp destination - files need to be restructured anyway
  SOURCE="$(mktemp -d)"
  trap "rm -rf $SOURCE" ERR
fi

if [[ ! -d "$SOURCE/runtime" ]]; then
  unzip -q "$RUNTIME_ZIP" -d "$SOURCE/runtime"
fi
if [[ ! -d "$SOURCE/jar" ]]; then
  unzip -q "$JAR_ZIP" -d "$SOURCE/jar"
fi

# Install relevant files...
rsync "$SOURCE/jar/zserio.jar" "$DESTINATION/zserio.jar"
rsync -aq "$SOURCE"/runtime/runtime_libs/* "$DESTINATION/runtime"
if [[ $WITH_PYTHON == "true" ]]; then
    rsync -aq "$DESTINATION"/runtime/python/zserio/*.py "$DESTINATION"
    rsync -aq "$DIR/patch/gen.py" "$DESTINATION"
    patch "$DESTINATION/__init__.py" "$DIR/patch/gen.patch"
    rm -f "$DESTINATION"/*.orig
fi

if [[ -n "${CACHE_DIR}" ]]; then
    rm -rf "${SOURCE}"
fi

# Extract version
ZSERIO_VERSION=$(java -jar "$DESTINATION/zserio.jar" -version | sed "s/version //g")
echo "$ZSERIO_VERSION" > "$DESTINATION/version.txt"
echo "Zserio version at $DESTINATION is now $ZSERIO_VERSION."
