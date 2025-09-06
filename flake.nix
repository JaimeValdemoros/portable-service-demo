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
        hello-service = pkgs.writeText "hello.service" (builtins.readFile ./hello.service);
      in
      {
        defaultPackage = pkgs.portableService {
          pname = "hello";
          version = "1.0";
          units = [ hello-service ];
          symlinks = [
            {
              object = "${pkgs.hello}/bin/hello";
              symlink = "/bin/hello";
            }
          ];
        };
        formatter = pkgs.nixfmt-tree;
        devShell =
          with pkgs;
          mkShell {
            buildInputs = [ squashfsTools ];
          };
      }
    );
}
