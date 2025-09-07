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
        cowsay-service = {
          name = "cowsay@.service";
          outPath =
            (pkgs.replaceVars (pkgs.writeText "cowsay.service" (builtins.readFile ./cowsay${"@"}.service)) {
              cowsayExe = "${pkgs.cowsay}/bin/cowsay";
            }).outPath;
        };
        cowsay-socket = {
          name = "cowsay.socket";
          outPath = "${./cowsay.socket}";
        };
      in
      {
        defaultPackage = pkgs.portableService {
          pname = "cowsay";
          version = "1.0";
          units = [
            cowsay-service
            cowsay-socket
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
