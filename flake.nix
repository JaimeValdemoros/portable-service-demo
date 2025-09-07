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
      in
      {
        defaultPackage = pkgs.portableService {
          pname = "caddyplugins";
          inherit (pkgs.caddy) version;
          units = [
            (pkgs.concatText "caddyplugins.service" [
              "${pkgs.caddy}/lib/systemd/system/caddy.service"
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
