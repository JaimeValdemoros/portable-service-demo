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
          inherit (pkgs.caddy) pname version;
          units = [
            (pkgs.concatText "caddy.service" [ "${pkgs.caddy}/lib/systemd/system/caddy.service" ])
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
