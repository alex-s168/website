{
  description = "Nix-built website and coffee service Incus images";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      sourceRevision = self.rev or "nix-source";
      sourceDate = self.lastModifiedDate or "19700101000000";

      perSystem = system:
        let
          pkgs = import nixpkgs { inherit system; };
          dhcpcdPath = pkgs.lib.makeBinPath [
            pkgs.coreutils
            pkgs.dhcpcd
            pkgs.gnused
            pkgs.inetutils
            pkgs.procps
            pkgs.util-linux
          ];
          python = pkgs.python3.withPackages (packages: with packages; [
            brotli
            feedgen
            fonttools
            requests
          ]);

          peopleJson = pkgs.runCommand "website-people.json" {
            nativeBuildInputs = [ pkgs.typst ];
          } ''
            ${pkgs.typst}/bin/typst query ${self}/common.typ "<meta-people>" \
              --root ${self} --input query=true --field value --one > "$out"
          '';
          people = builtins.fromJSON (builtins.readFile peopleJson);
          badgeUrls = pkgs.lib.mapAttrs (_id: person: person.badge)
            (pkgs.lib.filterAttrs (_id: person: person ? badge) people);
          badgeFiles = pkgs.lib.mapAttrs
            (id: url: builtins.fetchurl { name = "badge-${id}"; inherit url; })
            (builtins.removeAttrs badgeUrls [ "alex" ]);
          websiteSource = pkgs.runCommand "alex-website-source" { } ''
            mkdir -p "$out"
            cp -R ${self}/. "$out/"
            chmod -R u+w "$out"
            mkdir -p "$out/assets/badges"
            ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList
              (id: path: "cp ${path} $out/assets/badges/${id}")
              badgeFiles)}
          '';

          website = pkgs.stdenvNoCC.mkDerivation {
            pname = "alex-website";
            version = "1.0.0";
            src = websiteSource;

            nativeBuildInputs = [
              pkgs.curl
              pkgs.ffmpeg
              pkgs.minhtml
              pkgs.ninja
              pkgs.pngquant
              pkgs.typst
              python
            ];

            dontConfigure = true;
            buildPhase = ''
              runHook preBuild
              export SITE_REVISION=${sourceRevision}
              export SITE_COMMIT_DATE=${sourceDate}
              export WEBSITE_BADGE_PREFETCH_DIR=assets/badges
              mkdir -p build
              python config.py
              ninja -v web
              runHook postBuild
            '';

            installPhase = ''
              mkdir -p "$out"
              cp -R build/deploy/. "$out/"
            '';
          };

          coffee = pkgs.rustPlatform.buildRustPackage {
            pname = "coffee";
            version = "0.1.0";
            src = ./coffee;
            cargoLock.lockFile = ./coffee/Cargo.lock;
            nativeBuildInputs = [ pkgs.pkg-config ];
            buildInputs = [ pkgs.openssl ];
          };

          mkIncusImage = { name, description, rootPaths, init }:
            let
              closure = pkgs.closureInfo {
                rootPaths = rootPaths ++ [ init ];
              };
              rootfs = pkgs.runCommand "${name}-incus-rootfs" { } ''
                mkdir -p "$out"/{bin,dev,etc,nix/store,proc,root,run,sbin,sys,tmp,var/empty,var/lib/dhcpcd}
                ln -s /run "$out/var/run"
                touch "$out/etc/dhcpcd.conf"

                while IFS= read -r storePath; do
                  cp -a "$storePath" "$out/nix/store/"
                done < ${closure}/store-paths

                ln -s ${init} "$out/sbin/init"
                ln -s ${pkgs.bash}/bin/bash "$out/bin/bash"
                ln -s ${pkgs.bash}/bin/bash "$out/bin/sh"
                cat > "$out/etc/passwd" <<'EOF'
                root:x:0:0:root:/root:/bin/bash
                website:x:65532:65532:website:/var/empty:/bin/bash
                EOF
                cat > "$out/etc/group" <<'EOF'
                root:x:0:
                website:x:65532:
                EOF
              '';
            in
            pkgs.runCommand "${name}-incus-image.tar.gz" {
              nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ];
            } ''
              set -euo pipefail
              imageRoot="$TMPDIR/image"
              mkdir -p "$imageRoot/rootfs"
              cp -a ${rootfs}/. "$imageRoot/rootfs/"
              chmod 1777 "$imageRoot/rootfs/tmp"
              chmod 0755 "$imageRoot/rootfs/run" "$imageRoot/rootfs/var" \
                "$imageRoot/rootfs/var/lib" "$imageRoot/rootfs/var/lib/dhcpcd"

              cat > "$imageRoot/metadata.yaml" <<'EOF'
              architecture: ${if system == "x86_64-linux" then "x86_64" else "aarch64"}
              creation_date: ${toString (nixpkgs.lastModified or 1)}
              properties:
                name: ${name}
                description: ${description}
              EOF

              tar --sort=name --mtime='@1' --owner=0 --group=0 --numeric-owner \
                -C "$imageRoot" -cf - metadata.yaml rootfs | gzip -n > "$out"
            '';

          coffeeInit = pkgs.writeShellScript "website-coffee-init" ''
            set -euo pipefail
            export NETWORK_INTERFACES="''${NETWORK_INTERFACES:-}"
            export COFFEE_BIND="''${COFFEE_BIND:-0.0.0.0}"
            export COFFEE_PORT="''${COFFEE_PORT:-3000}"
            export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
            export PATH=${dhcpcdPath}

            if [[ -n $NETWORK_INTERFACES ]]; then
              read -r -a interfaces <<< "$NETWORK_INTERFACES"
            else
              interfaces=()
              for interface_path in /sys/class/net/*; do
                interface="''${interface_path##*/}"
                [[ $interface == lo ]] || interfaces+=("$interface")
              done
            fi
            if ((''${#interfaces[@]} == 0)); then
              echo "no network interfaces found for DHCP" >&2
              exit 2
            fi
            for interface in "''${interfaces[@]}"; do
              if [[ ! $interface =~ ^[a-zA-Z0-9_.:-]+$ ]]; then
                echo "invalid network interface name: $interface" >&2
                exit 2
              fi
            done

            ${pkgs.coreutils}/bin/mkdir -p /run/dhcpcd /var/lib/dhcpcd
            for interface in "''${interfaces[@]}"; do
              echo "Waiting for DHCP lease on $interface" >&2
              if ! ${pkgs.dhcpcd}/bin/dhcpcd --waitip "$interface"; then
                echo "error: failed to obtain a DHCP lease on $interface" >&2
                exit 1
              fi
            done

            exec ${pkgs.tini}/bin/tini -g -- \
              ${pkgs.util-linux}/bin/setpriv --reuid=65532 --regid=65532 --clear-groups \
              ${coffee}/bin/coffee
          '';
          coffeeIncusImage = mkIncusImage {
            name = "website-coffee";
            description = "Nix-built coffee price API service";
            init = coffeeInit;
            rootPaths = [
              pkgs.bash
              pkgs.cacert
              pkgs.coreutils
              pkgs.dhcpcd
              pkgs.tini
              pkgs.util-linux
              coffee
            ];
          };

          nginxConfigTemplate = pkgs.writeText "website-nginx.conf.template" ''
            worker_processes 1;
            pid /tmp/nginx/nginx.pid;
            error_log stderr warn;

            events {
              worker_connections 1024;
            }

            http {
              include ${pkgs.nginx}/conf/mime.types;
              default_type application/octet-stream;
              access_log off;
              sendfile on;
              server_tokens off;
              client_body_temp_path /tmp/nginx/client_body;
              proxy_temp_path /tmp/nginx/proxy;

              upstream coffee_backend {
                server ''${COFFEE_HOST}:''${COFFEE_PORT};
              }

              server {
                listen 8080;
                root ${website};
                index index.html;

                location = /coffee {
                  return 301 /coffee/;
                }

                location ^~ /coffee/ {
                  proxy_pass http://coffee_backend/;
                  proxy_http_version 1.1;
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                }

                location / {
                  try_files $uri $uri/ =404;
                }
              }
            }
          '';
          nginxEntrypoint = pkgs.writeShellScript "website-nginx-entrypoint" ''
            set -euo pipefail
            export COFFEE_HOST="''${COFFEE_HOST:-coffee}"
            export COFFEE_PORT="''${COFFEE_PORT:-3000}"

            if [[ ! $COFFEE_HOST =~ ^([A-Za-z0-9][A-Za-z0-9.-]*|\[[0-9A-Fa-f:.]+\])$ ]]; then
              echo "COFFEE_HOST must be a hostname, IPv4 address, or bracketed IPv6 address" >&2
              exit 2
            fi
            if [[ ! $COFFEE_PORT =~ ^[0-9]{1,5}$ ]] || \
              (( 10#$COFFEE_PORT < 1 || 10#$COFFEE_PORT > 65535 )); then
              echo "COFFEE_PORT must be an integer from 1 to 65535" >&2
              exit 2
            fi

            ${pkgs.coreutils}/bin/mkdir -p /tmp/nginx/client_body /tmp/nginx/proxy
            ${pkgs.gettext}/bin/envsubst '$COFFEE_HOST $COFFEE_PORT' \
              < ${nginxConfigTemplate} > /tmp/nginx/nginx.conf
            exec ${pkgs.nginx}/bin/nginx -e stderr -c /tmp/nginx/nginx.conf -g 'daemon off;'
          '';
          nginxInit = pkgs.writeShellScript "website-nginx-init" ''
            set -euo pipefail
            export NETWORK_INTERFACE="''${NETWORK_INTERFACE:-eth0}"
            export PATH=${dhcpcdPath}

            ${pkgs.coreutils}/bin/mkdir -p /run/dhcpcd /var/lib/dhcpcd
            if ! ${pkgs.dhcpcd}/bin/dhcpcd --waitip "$NETWORK_INTERFACE"; then
              echo "error: failed to obtain a DHCP lease on $NETWORK_INTERFACE" >&2
              exit 1
            fi

            exec ${pkgs.tini}/bin/tini -g -- \
              ${pkgs.util-linux}/bin/setpriv --reuid=65532 --regid=65532 --clear-groups \
              ${pkgs.bash}/bin/bash ${nginxEntrypoint}
          '';
          websiteIncusImage = mkIncusImage {
            name = "website-nginx";
            description = "Nix-built website served by nginx with coffee API proxy";
            init = nginxInit;
            rootPaths = [
              pkgs.bash
              pkgs.coreutils
              pkgs.dhcpcd
              pkgs.gettext
              pkgs.nginx
              pkgs.tini
              pkgs.util-linux
              website
            ];
          };

          incusImages = pkgs.linkFarm "website-incus-images" [
            { name = "coffee-image.tar.gz"; path = coffeeIncusImage; }
            { name = "website-image.tar.gz"; path = websiteIncusImage; }
          ];
        in
        {
          inherit website coffee coffeeIncusImage websiteIncusImage incusImages;
          devShell = pkgs.mkShell {
            packages = [
              pkgs.cargo
              pkgs.curl
              pkgs.ffmpeg
              pkgs.git
              pkgs.pkg-config
              pkgs.minhtml
              pkgs.ninja
              pkgs.pngquant
              pkgs.rustc
              pkgs.typst
              python
            ];
          };
        };
    in
    {
      packages = forAllSystems (system:
        let outputs = perSystem system;
        in {
          default = outputs.incusImages;
          site = outputs.website;
          coffee = outputs.coffee;
          coffee-incus-image = outputs.coffeeIncusImage;
          website-incus-image = outputs.websiteIncusImage;
          incus-images = outputs.incusImages;
        });

      devShells = forAllSystems (system: {
        default = (perSystem system).devShell;
      });
    };
}
