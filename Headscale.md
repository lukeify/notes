# [Headscale][1]

Provides an open-source re-implementation of the Tailscale control server, while preserving the ability to use Tailscale-provided applications and tools on clients.
This application is written in Go.

## Installation

Follow the [Linux installation steps][2].
Before doing so however:

1. Have the CNAME record for the subdomain that you intend to host Headscale on pre-configured.
2. Configure an email address for the ACME provider to deliver LetsEncrypt certificate renewal emails to.

Headscale can automatically retrieve a LetsEncrypt certificate for your `headscale` instance when providing a domain operating on port 443.
To enable this, ensure the `server_url` and `listen_addr` within the configuration are set to be `https`, and an address ending in `:443`, respectively.

Once configured, run `headscale` as a `systemd` service via `systemctl start headscale`.
Debugging headscale run failures can be done with `journalctl -u headscale.service -n 100 -f` (or alternatively by running headscale interactively via `headscale`).

### Reverse Proxy Configuration

By default, Headscale does not provide out of the box configuration to be located behind a reverse proxy, [and such resources are community maintained][2b].
With NGINX however, the process is reasonably simple:

1. Unset any TLS configuration settings from the Headscale `config.yaml` file:
   1. `acme_url` (left set for documentation purposes),
   2. `acme_email`,
   3. `tls_letsencrypt_hostname`,
   4. `tls_letsencrypt_cache_dir` (left set for documentation purposes),
   5. `tls_letsencrypt_challenge_type` (left set for documentation purposes),
   6. `tls_letsencrypt_listen`,
   7. `tls_cert_path`,
   8. `tls_key_path`

   Note that the `server_url` setting retains its `https://` suffix.
2. Introduce an `nginx` [configuration][2c] that enables SSL termination at the `nginx` level before passing on the traffic with the `proxy_*` directives.
   It's important to set the `Upgrade` and `Connection` headers appropriately in the proxy configuration—this is needed to pass WebSockets through.
3. Generate an SSL certificate for the server using `certbot`.
4. Restart `nginx` and `headscale`.

### Metrics

Metrics can be made public by configuring a separate `nginx` location block that points to the `metrics_listen_addr` specified in the Headscale configuration.
This is a response in "Prometheus Exposition Format", with each metric being annotated with metadata prefixed with `# HELP` and `# TYPE`.

TODO: How can this be made private?

## Tailnet naming

Your client will initially report your Tailnet name as being `user@example.com` (where `user` is the username you provided).
This can be modified by configuring the `dns_config.base_domain` key in the `config.yaml` file in the Headscale coordination service to a domain of your choosing.

![Tailnet naming in macOS client](./images/headscale/tailnet-naming.png)

## macOS Tailscale client configuration

Install the standalone Tailscale client application for macOS directly from Tailscale, [as this has a number of advantages][3].
This is documented in the [comparison table][4].

* Allowing system extensions for macOS with Tailscale client

## Policy files

A tailnet policy file can be provided to Headscale to implement access control via ACLs.
This file is written in [HuJSON][5] (Human JSON), which is a Tailscale implementation of [JWCC][6] ("JSON with Commas and Comments").
Provide a tailnet policy file by specifying a filename to the `acl_policy_path` key within the Headscale configuration.

Note that `Headscale` will fail to start if provided a policy file with zero ACL's inside of it—even an empty `acls` array is not sufficient.

## Nodes

https://tailscale.com/kb/1111/ephemeral-nodes

## Tailscale CLI

Tailscale ships with two command line tools.
These are installed on nodes that participate in the tailnet:

* `tailscaled`, a daemon which manages networking and usually is not interacted with. [Flags that can be passed here][6a].
* `tailscale`, the CLI to manage the tailscale network, login, logout, etc. [Command reference here][6b].

### CLI Notes

* Currently, it is only possible to expire API keys generated from the Headscale server, not delete them.
    Deleting keys involves [modifying the contents of the SQLite database][7] Headscale uses to store information within.
    However, this [feature has been landed][8] on the main branch for the next release.

## Headscale UI

Headscale does not ship with a native GUI, you can self-host [headscale-ui][9]—a third-party GUI for the headscale project—instead.
This is a static site that is expected to be hosted from the same subdomain that the Headscale control server runs on, under the `web/` subdirectory.
Built with svelte, it can be initialised with:

```bash
npm install
npm run build
```

And then served over `nginx` via:

```nginx
location /web {
    alias /var/www/headscale-ui-2024.02.24-beta1/build/;
    index index.html;
}
```

Provide it with an API key to address your headscale control server by generating one with `sudo headscale apikeys create`.

## DNS

Tailscale clients can use the DNS provided by the tailscale control server when configured, or can ignore it with `--accept-dns=false` (documentation) argument to the tailscale CLI.

Additionally, extra A (or [AAAA][10]) DNS records can be provided to associate node IP addresses with human-friendly domain names.
This can be configured in the headscale `config.yaml` file:

```yaml
dns:
  extra_records:
    - name: "my.dns.record.example"
      type: "A"
      value: "100.64.0.1"
```

Confirm your record via `dig`.

TODO:

https://tailscale.com/kb/1054/dns
https://tailscale.com/kb/1081/magicdns
https://tailscale.com/kb/1033/ip-and-dns-addresses?tab=macos

## Headscale API

Compared to the [Tailscale API][11], Headscale's functionality and documentation is thin.
Requests to the Headscale can be made at your headscale control plane's endpoint, with authentication taking place via a `Authorization` header being provided an API key generated from `sudo headscale apikeys create`:

```bash
curl https://hs.example/api/v1/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <API_KEY>"
```

A full list of API endpoints for Headscale can be found and viewed using the OpenAPI Specification plugin within IntelliJ to explore the [`gen/go/openapiv2/headscale/v1/headscale.swagger.json`][12] file.

## Usage with <span data-nospell>Fly.io</span>

* How to run tailscale in an image for <span data-nospell>fly.io</span>?

## Further reading & watching

* [Self Host Tailscale with Headscale - How To Setup][13] by Jim's Garage, YouTube

[1]: https://headscale.net
[2]: https://headscale.net/running-headscale-linux/
[2b]: https://headscale.net/reverse-proxy/
[2c]: https://headscale.net/reverse-proxy/#nginx
[3]: https://tailscale.com/kb/1065/macos-variants
[4]: https://tailscale.com/kb/1065/macos-variants#comparison-table
[5]: https://github.com/tailscale/hujson
[6]: https://nigeltao.github.io/blog/2021/json-with-commas-comments.html
[6a]: https://tailscale.com/kb/1278/tailscaled#flags-to-tailscaled
[6b]: https://tailscale.com/kb/1080/cli#command-reference
[7]: https://github.com/juanfont/headscale/issues/1667#issuecomment-1951606032
[8]: https://github.com/juanfont/headscale/pull/1702
[9]: https://github.com/gurucomputing/headscale-ui
[10]: https://github.com/tailscale/tailscale/blob/6edf357b96b28ee1be659a70232c0135b2ffedfd/ipn/ipnlocal/local.go#L2989-L3007
[11]: https://tailscale.com/api
[12]: https://github.com/juanfont/headscale/blob/main/gen/openapiv2/headscale/v1/headscale.swagger.json
[13]: https://www.youtube.com/watch?v=OECp6Pj2ihg

TODOS:

* How to enable GRPC for remotely controlling headscale server via the CLI?
