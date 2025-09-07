{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        caddy = pkgs.caddy.withPlugins {
          plugins = [
            "github.com/hairyhenderson/caddy-teapot-module@v0.0.3-0"
          ];
          hash = "sha256-+8BLuvRPAjj8bk74UdDpT/E/vg4daAgz8MUa68aYMr4=";
        };
      in
      {
        defaultPackage = pkgs.portableService {
          pname = "caddyplugins";
          inherit (caddy) version;
          units = [
            (pkgs.concatText "caddyplugins.service" [
              "${caddy}/lib/systemd/system/caddy.service"
              ./caddy.service
            ])
            (pkgs.concatText "caddyplugins.socket" [
              ./caddy.socket
            ])
          ];
          symlinks = [
            {
              object = ./Caddyfile;
              symlink = "/etc/caddy/Caddyfile";
            }
          ];
        };
        formatter = pkgs.nixfmt-tree;
        devShell =
          with pkgs;
          mkShell {
            buildInputs = [
              cowsay
              squashfsTools
            ];
          };
      }
    );
}
