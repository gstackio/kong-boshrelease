# Depreciation notice

This BOSH Release has been superseded by the
[gk-kong-boshrelease](https://github.com/gstackio/gk-kong-boshrelease) which
brings solutions to the numerous [issues](./issues) raised here, and provides
newer versions of Kong.

You should definitely go there and not care about this temporary fork project.



# BOSH Release for Kong Community Edition (CE)

This BOSH Release was the fastest way to get up and running with a cluster of
[Kong Community Edition (CE)][kong-ce] API Gateway when you're using BOSH.

[kong-ce]: https://konghq.com/kong-community-edition/

This BOSH Release provides all the necessary binaries, configuration
templates, and startup scripts for converging Kong clusters (which is
basically the point of a BOSH Release). Plus, we also provide here a standard
[deployment manifest][depl-manifest] to help you deploy your first Kong API
Gateway easily.

[depl-manifest]: ./manifests/kong.yml

## Usage

This repository includes base manifests and operator files. They can be used
for initial deployments and subsequently used for updating your deployments.

```
git lfs version   # check that you have the 'git-lfs' extension
git clone https://github.com/gstackio/kong-ce-boshrelease.git

export BOSH_ENVIRONMENT=<bosh-alias>
export BOSH_DEPLOYMENT=kong
bosh deploy kong-ce-boshrelease/manifests/kong.yml
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

### Clustering

Clustering Kong API Gateways is unfortunately [flawed](./releases/tag/v1.0.0).
This issue has been fixed in the new “reboot”
[gk-kong-boshrelease][gk_kong_boshrelease] project.

Normally it should have worked out of the box, with a mere updating of the
[`instances:` property][instances-prop] in the deployment manifest. Kong nodes
will synchronize their state on the shared PostgreSQL database, with
[some caching implemented][db_update_frequency_doc].

[gk_kong_boshrelease]: https://github.com/gstackio/gk-kong-boshrelease
[instances-prop]: https://github.com/gstackio/kong-ce-boshrelease/blob/v1.0.0/manifests/kong.yml#L7
[db_update_frequency_doc]: https://docs.konghq.com/0.11.x/clustering/#1-db_update_frequency-default-5s

You can update the `db_update_frequency` value (default is 5 seconds), adding
it to the [`kong_conf` property][kong_conf_prop] in the deployment manifest.
Please note though, that the default deployment manifest doesn't provide you
with any High Availability (HA) or horizontal scaling solution for the
PostgreSQL database. If you stick to it, this will still be a single point of
failure.

[kong_conf_prop]: https://github.com/gstackio/kong-ce-boshrelease/blob/v1.0.0/manifests/kong.yml#L15

If you are concerned with HA design for Kong, we encourage you to have a look
at the [Cassandra BOSH Release][cassandra-release] that we're also
contributing to. You'll need a basic understading of the Cassandra technology
(tombstones, repairs, etc) but building a BOSH deployment manifest that
integrates Kong with Cassandra should be pretty straightforward, just reading
[Kong's documentation][cassandra-config-doc].

[cassandra-release]: https://github.com/orange-cloudfoundry/cassandra-boshrelease
[cassandra-config-doc]: https://docs.konghq.com/0.11.x/configuration/#cassandra-settings

## Design notes

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

## Contributing

Pull requests are welcome! See in our [open issues][issues] the possible
improvements that you could contribute to. They are prioritized by
[milestones][milestones] that each expose a specific goal.

[issues]: https://github.com/gstackio/kong-ce-boshrelease/issues
[milestones]: https://github.com/gstackio/kong-ce-boshrelease/milestones

As a notice to release authors that contribute here, this BOSH Release is
based on a [Git LFS blobstore][git-lfs-blobstore]. This is quite uncommon, so
please read [Ruben Koster's post][git-lfs-blobstore] first before continuing.

[git-lfs-blobstore]: https://starkandwayne.com/blog/bosh-releases-with-git-lfs/

Blobs can be commited to Git here because they are backed by Git LFS. Using
`bosh sync-blobs` is thus no more necessary because you get the correct final
blobs with a mere `git pull`.

Whenever you need to update the blobs, you'll find in the
`scripts/add-blobs.sh` script the way we have been fetching them. This helps
in fetching any newer versions of the softwares. The `add-blobs.sh` script is
also best practice in authoring BOSH Releases.

## Author and License

Copyright © 2018, Benjamin Gandon, Gstack

Like the rest of BOSH, this Kong CE BOSH Release is released under the terms
of the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0).
