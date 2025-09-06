{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        hello-service = pkgs.writeText "hello.service" ''
          [Unit]
          Description=Hello world

          [Service]
          Type=oneshot
          ExecStart=${pkgs.hello}/bin/hello

          [Install]
          WantedBy=multi-user.target default.target
        '';
      in {
        defaultPackage = pkgs.portableService {
          pname = "hello";
          version = "1.0";
          units = [ hello-service ];
        };
        devShell = with pkgs; mkShell {
          buildInputs = [squashfsTools];
        };
      }
    );
}
