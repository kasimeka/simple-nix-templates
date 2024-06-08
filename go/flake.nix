{
  nixConfig.bash-prompt-prefix = ''(go) '';

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = inputs.nixpkgs.legacyPackages."${system}";
      unstable = inputs.nixpkgs-unstable.legacyPackages."${system}";

      drv = let
        pname = "henlo";
        version = "v0.0.0-dev";
      in
        pkgs.buildGoModule {
          inherit pname version;

          src = with unstable.lib.fileset;
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
        packages =
          [pkgs.bashInteractive]
          ++ (with unstable; [
            gofumpt
            gopls
            gotools
            delve

            gnumake
          ]);
        shellHook = ''
          export PATH="$HOME/go/bin:$PATH"
          echo "with love from wrd :)"
        '';
      };
    });
}
