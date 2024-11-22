# Fly.io

No IaC story at the moment. Had a previous terraform provider but was discontinued. Manage infrastructure through the web GUI or `flyctl` CLI.

## [Pricing][1]

There is no "free allowance" on new fly.io plans (referred to as "Pay As You Go"), instead, you pay for compute resources as you use them.
However bills that accumulate a usage of less than US$5.00/mo are currently waived.

For the majority of apps, fly machines in the `shared-cpu-1x` category will be sufficient.
As an example, for a near-stock Rails app that was deployed to the Sydney region, the resources created were:

* A `shared-cpu-1x-1024` maachine to host the Rails app proper (incurring a US$7.23/mo bill).
* An additional `shared-cpu-1x-256` to support the corresponding database (US$2.47/mo).
* A volume to back the data stored in this database (initially a 1GB volume, billed at US$0.15/GB/mo).

Apps that are shutdown but persist on Fly.io accumulate a RootFS storage fee of $0.15/GB/month—this covers the cost of the file system, and is based on your OCI image generated from your app.
[This change took effect from April 2024][2].

## Deployment

An example deployment flow using `fly.io` for a Ruby on Rails app.

### Initialization

Although fly.io can create deploy an application from a repository with a single command (`flyctl launch`), this reduces the amount of customisation available.
Additionally, often secrets that are required for the Rails app to boot will not be present in the initial Docker machine image that fly.io will create and changes will be needed.
Instead, an application can be registered using:

```bash
fly apps create APP_NAME
```

This will create an instance of an application with no machines attached.

### Integrating secrets

Secrets can be added to an application without redeploying using the staging command:

```bash
fly secrets set SECREY_KEY=secret_value --stage
```

Add TAILSCALE_AUTHKEY secret
Add RAILS_SECRET_KEY_BASE secret

### Attaching services



### Build configuration

### Launching


`fly deploy` will automatically provision 2 machines.
Specifying false high availability will reduce this to one—this is beneficial for non-production environments.
There does not appear to be a `fly.toml` configuration for this.

```bash
flyctl deploy --ha=false
```


```bash
flyctl launch --no-deploy
```


https://community.fly.io/t/setting-secrets-before-the-first-deployment-does-nothing/5589/7


### Runtime secrets

### Networking

Apps created with Fly.io are immediately assigned an IP address and provided with a `.fly.dev` domain name.
The public-facing IP address can be removed via either `flyctl` or through the GUI.

TODO:

https://fly.io/docs/blueprints/private-applications-flycast/
https://fly.io/docs/blueprints/connect-private-network-wireguard/
https://tailscale.com/kb/1132/flydotio
https://community.fly.io/t/accessing-an-external-non-public-resource-from-your-fly-io-app/10180
https://community.fly.io/t/connecting-your-fly-apps-to-your-tailscale-tailnet/17828
https://thisisfranklin.com/2023/01/13/running-rails-on-flyio-with-tailscale.html
https://fly.io/docs/networking/flycast/
https://fly.io/docs/blueprints/autostart-internal-apps/
https://tailscale.com/kb/1153/enabling-https
https://tailscale.com/kb/1054/dns

[1]: https://fly.io/docs/about/pricing/
[2]: https://community.fly.io/t/we-are-going-to-start-collecting-charges-for-stopped-machines-rootfs-starting-april-25th/17825
