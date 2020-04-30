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
zserio.require("mypackage/all.zs", package_prefix="mypackage")

# You can now access structs from your zserio sources!
from mypackage.all import CoolStruct
```

## Running tests

Just execute

```bash
pytest test
```

## Updating package with a new Zserio version 

* __Step 1:__ Update the `zserio-official` submodule to the required version.
* __Step 2:__ Execute `./update.sh`
* __Step 3:__ Commit/Push (Appropriate Adds/Removes are performed automatically)
* __Step 4:__ Execute `./deploy.sh`
