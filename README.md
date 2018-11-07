# BOSH Release for Kong Community Edition (CE)

This BOSH Release is the fastest way to get up and running with a cluster of
[Kong Community Edition (CE)][kong-ce] API Gateway when you're using BOSH.

[kong-ce]: https://konghq.com/kong-community-edition/

This BOSH Release provides all the necessary binaries, configuration
templates, and startup scripts for converging Kong clusters (which is
basically the point of a BOSH Release). Plus, we also provide here a standard
[deployment manifest][depl-manifest] to help you deploy your first Kong API
Gateway easily.

[depl-manifest]: ./manifests/kong.yml

## Notice

This is a forked version of the Community's [kong-boshrelease][kong-release],
that sticks to a compiled install design, over a Docker-based design. Here we
have fixed many minor glitches for Kong to actually work, and in terms of BOSH
Release authoring, we have generally brought more best practice in.

[kong-release]: https://github.com/cloudfoundry-community/kong-boshrelease

Here we have abandoned the Docker container design, because it breaks the
general Operating System update workflow proposed by BOSH with Stemcells.
That's why (Docker) images-based BOSH Release are generally meant for
development and testing.

Plus, the [original release][kong-release] is non-hermetic, because it is
based on the `kong:latest` Docker image. For BOSH deployments relying on such
non-hermetic build, there is risk of being non-reproductible. Given a same set
of Release and Stemcell versions, a braking change in the `kong:latest` image
could break your Kong deployment from staging to production because you're
never 100% sure that you're pushing in production the same image that has been
validated in your staging environment.

As we generally want to get closer from production, we've gone back here to a
conventional BOSH packaging for a more hermetic build that compiles what's
necessary on top of the BOSH Stemcell.

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

## Contributing

As a notice to release authors that contribute here, this BOSH Release is
based on a [Git LFS blobstore][git-lfs-blobstore]. This is quite uncommon, so
please read [Ruben Koster's post][git-lfs-blobstore] first before continuing.

[git-lfs-blobstore]: https://starkandwayne.com/blog/bosh-releases-with-git-lfs/

Contrarily to common practice with BOSH, blobs are commited to Git, because
they are backed by Git LFS, and `bosh sync-blobs` is no more necessary because
you get the correct final blobs with `git pull`.
