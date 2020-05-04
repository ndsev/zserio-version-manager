# Zserio Package

PyPI package infrastructure around Zserio. For extensive
documentation around the zserio language please check
[zserio.org](http://zserio.org).

## Installation

Just run

```bash
pip3 install zserio
```

Alternatively, clone this repository, and run

```bash
./set-version.sh <desired-zserio-version>
pip3 install -e .
```

## Importing zserio package sources

```py
import zserio

# Automatically inserts a new python module called `mypackage`
#  into the current python environment
zserio.generate("mypackage/all.zs", "mypackage")

# You can now access structs from your zserio sources!
from mypackage.all import CoolStruct
```

## Running tests

Just execute

```bash
pytest test
```

## Available scripts: 

### get.sh \<version> \[\<destination>]

Set the zserio PIP package version under a specific destination
path (or `./current/zserio`, if no destination is given)
to a desired version. If the version has not been added to
`./cache`, it will be downloaded and placed there. You should
`git add/push` it.

The script places the following files under `<destination>`:
* `runtime/`
    * `cpp/...`
    * `java/...`
    * `python/...`
* `__init__.py`
* `(zserio runtime python sources...)`
* `zserio.jar`
* `version.txt`

### download.sh \<version>

Use this if you just want to add a new zserio version
to the cache (This is also triggered by `get.sh`
if a non-cached version is requested).
