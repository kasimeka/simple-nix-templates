{
  nixConfig.bash-prompt-prefix = ''(go) '';

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = inputs.nixpkgs.legacyPackages."${system}";

      drv = let
        pname = "henlo";
        version = "0.0.0-dev";
      in
        pkgs.buildGoModule {
          inherit pname version;

          src = with pkgs.lib.fileset;
            toSource {
              root = ./.;
              fileset = unions [
                ./go.mod
                ./go.sum
                (fileFilter (file: file.hasExt "go") ./.)
              ];
            };

          vendorHash = null;

          __darwinAllowLocalNetworking = true;
        };
    in {
      packages.default = drv;
      devShells.default = pkgs.mkShell {
        inputsFrom = [drv];
        packages = with pkgs; [
          bashInteractive
          gofumpt
          gopls
          gotools
          delve

          gnumake
        ];
        shellHook = ''
          export PATH="$HOME/go/bin:$PATH"
          echo "with love from wrd :)"
        '';
      };
    });
}
