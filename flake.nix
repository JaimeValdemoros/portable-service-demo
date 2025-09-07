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
          pname = "cowsay";
          version = "1.0";
          units = [
            {
              name = "cowsay@.service";
              outPath = (pkgs.writeText "cowsay.service" (builtins.readFile ./cowsay${"@"}.service)).outPath;
            }
            {
              name = "cowsay.socket";
              outPath = "${./cowsay.socket}";
            }
          ];
          symlinks = [
            {
              object = "${pkgs.cowsay}/bin/cowsay";
              symlink = "/bin/cowsay";
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
