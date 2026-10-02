# alex-s168 website

The static website is built through the existing `config.py` + Ninja pipeline.
Nix packages it with two Incus-native container images:

- `website-coffee`: the Rust/Axum coffee-price API.
- `website-nginx`: the static site served by Nginx, with `/coffee/` proxied to
the coffee instance.

## Build and import the Incus images

Requirements: Nix with flakes enabled and an installed Incus client/server.

```sh
nix build --impure --refresh .#incus-images
incus image import result/coffee-image.tar.gz --alias website-coffee
incus image import result/website-image.tar.gz --alias website-nginx
```

`--refresh` checks the badge URLs stored in the people records in `common.typ`.
Nix reads them through the same Typst metadata query used by Ninja, fetches them
as explicit store inputs, then supplies those files to the sandboxed website
build. Ordinary local Ninja builds leave that setting unset and run the
`curl always` badge rule directly.

## Launch the services

Launch the coffee API first:

```sh
incus launch website-coffee coffee
incus list coffee
```

Use the coffee instance's reachable IP address or DNS name for `COFFEE_HOST`
when launching the website image. For example, replace `10.0.0.42` below with
the address shown for the coffee instance by `incus list`:

```sh
incus launch website-nginx website \
  -c environment.COFFEE_HOST=10.0.0.42 \
  -c environment.COFFEE_PORT=3000
incus list website
```

The website container listens on port `8080`; connect to that port on its
Incus-reported address. Nginx proxies `/coffee/usd_eur`, `/coffee/ada_usd`, and
`/coffee/price/<country>` to the corresponding coffee API routes, stripping the
`/coffee/` prefix. The `COFFEE_HOST` default is `coffee`, and both containers
default to port `3000`. Nginx resolves the configured upstream when it starts;
Incus may not resolve the short name `coffee` on your network, so use the
coffee instance's reachable IP address or resolvable DNS name. To fix an
already-created website instance, update the value and restart it:

```sh
incus config set alex-website-website environment.COFFEE_HOST 10.0.0.42
incus restart alex-website-website
```

The coffee image discovers all non-loopback guest interfaces at startup and
waits for a DHCP address on each before starting the service, so both Incus
NICs are covered even if the kernel assigns them names other than `eth0`/`eth1`.
Set the space-separated
`NETWORK_INTERFACES` value only if you need to select specific interfaces, for
example:

```sh
incus config set coffee environment.NETWORK_INTERFACES "enp5s0 enp6s0"
incus restart coffee
```

Leave `NETWORK_INTERFACES` unset to use automatic discovery. Coffee listens on
`0.0.0.0:3000` by default; with DHCP-managed NICs, keep `COFFEE_BIND` at
`0.0.0.0` rather than binding to an address before DHCP assigns it.

The website image starts DHCP on `eth0`; override its `NETWORK_INTERFACE` if
that guest-visible NIC has a different name. Both services run as UID/GID
`65532`. `COFFEE_PORT` can be changed on both instances, but must match the
Nginx upstream port. The three coffee data-source URLs are hardcoded in the
service and require outbound network access at runtime.

## Individual outputs

```sh
nix build .#coffee-incus-image
nix build .#website-incus-image
nix build .#site
```

The website build tools are also available in `nix develop`; run `ninja web` to
build the site locally. Generated files are written to `build/deploy/`.
The timezone/country input remains checked in at
`build-input/countries.json`.
