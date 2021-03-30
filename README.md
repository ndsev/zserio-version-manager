# Zserio Package

Artifact version management for the zserio serialization framework.
For extensive documentation regarding zserio, please check
[zserio.org](http://zserio.org).

## Available scripts: 

### get.sh \[--version\] \[--directory\]

Set the zserio artifact version under a specific destination
path (or `./current/zserio`, if no destination is given)
to a desired version. If the version has not been added to
`./cache`, it will be downloaded and placed there. You should
`git add/push` it. 

The script places the following files under `<directory>`:
* `runtime/`
    * `cpp/...`
    * `java/...`
    * `python/...`
* `zserio.jar`
* `version.txt`

### download.sh \<version>

Use this if you just want to add a new zserio version
to the cache (This is also triggered by `get.sh`
if a non-cached version is requested).
