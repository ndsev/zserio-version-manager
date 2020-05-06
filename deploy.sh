#!/usr/bin/env bash
set -eu

if [[ ! -f current/zserio/version.txt ]]; then
  echo "No version selected! Please run ./set-version <version>."
  exit 1
fi

rm -rf dist
python setup.py sdist bdist_wheel
twine upload dist/*
