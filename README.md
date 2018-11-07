# BOSH Release for Kong Community Edition (CE)

This BOSH release and deployment manifest deploy a cluster of [Kong][kong-ce].

[kong-ce]: https://konghq.com/kong-community-edition/

## Notice

This is a forked version of the Community's [kong-boshrelease][kong-release]
with fixes and best practice implemented in terms of authoring a BOSH Release.

[kong-release]: https://github.com/cloudfoundry-community/kong-boshrelease

Here we have abandoned the Docker container design, going back to conventional
BOSH packaging for a more hermetic build that recompiles what's necessary.

## Usage

This release doesn't publish its blobs yet. This means you have to download
them manually and bundle/upload your release by yourself. No big deal! To help
you doing that, and following BOSH best practice, we provide an `add-blobs.sh`
script to fetch, verify and add the blobs where they should be.

```
export BOSH_ENVIRONMENT=<bosh-alias>
git clone https://github.com/gstackio/kong-ce-boshrelease.git
cd kong-ce-boshrelease
./scripts/add-blobs.sh
bosh create-release --force
bosh upload-release
```

This repository includes base manifests and operator files. They can be used
for initial deployments and subsequently used for updating your deployments:

```
export BOSH_ENVIRONMENT=<bosh-alias>
export BOSH_DEPLOYMENT=kong
cd kong-ce-boshrelease
bosh deploy manifests/kong.yml
```

If your BOSH does not have Credhub/Config Server (but it should), then
remember to use `--vars-store` to allow generation of passwords and
certificates.

### Update

When new versions of `kong-ce-boshrelease` are released, the
`manifests/kong.yml` file is updated. This means you can easily `git pull` and
`bosh deploy` to upgrade.

```
export BOSH_ENVIRONMENT=<bosh-alias>
export BOSH_DEPLOYMENT=kong
cd kong-ce-boshrelease
git pull
bosh deploy manifests/kong.yml
```
