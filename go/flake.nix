{
  nixConfig.bash-prompt-prefix = ''(go) '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs: let
    forAllSystems = f:
      inputs.nixpkgs.lib.genAttrs
      (import inputs.systems)
      (system: f inputs.nixpkgs.legacyPackages.${system});
    drv = let
      pname = "henlo";
      version = "0.0.0-dev";
    in
      {
        lib,
        buildGoModule,
      }:
        buildGoModule {
          inherit pname version;

          src = with lib.fileset;
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
    packages = forAllSystems (pkgs: {default = pkgs.callPackage drv {};});
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        inputsFrom = [inputs.self.packages.${pkgs.system}.default];
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
  };
}
