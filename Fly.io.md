# Fly.io

No IaC story at the moment. Had a previous terraform provider but was discontinued. Manage infrastructure through the web GUI or `flyctl` CLI.

## [Pricing][1]

There is no "free allowance" on new fly.io plans (referred to as "Pay As You Go"), instead, you pay for compute resources as you use them.

For the majority of apps, fly machines in the `shared-cpu-1x` category will be sufficient.
As an example, for a near-stock Rails app that was deployed to the Sydney region, the resources created were:

* A `shared-cpu-1x-1024` maachine to host the Rails app proper (incurring a US$7.23/mo bill).
* An additional `shared-cpu-1x-256` to support the corresponding database (US$2.47/mo).
* A volume to back the data stored in this database (initially a 1GB volume, billed at US$0.15/GB/mo).

Apps that are shutdown but persist on Fly.io accumulate a RootFS storage fee of $0.15/GB/month—this covers the cost of the file system, and is based on your OCI image generated from your app.
[This change took effect from April 2024][2].

[1]: https://fly.io/docs/about/pricing/
[2]: https://community.fly.io/t/we-are-going-to-start-collecting-charges-for-stopped-machines-rootfs-starting-april-25th/17825
