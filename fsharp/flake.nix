{
  nixConfig.bash-prompt-prefix = ''(fsharp) '';
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs: let
    forAllSystems = f:
      inputs.nixpkgs.lib.genAttrs
      (import inputs.systems)
      (system: f inputs.nixpkgs.legacyPackages.${system});
  in {
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          bashInteractive
          dotnet-sdk
          fsautocomplete
        ];
        env = {
          DOTNET_NOLOGO = "1";
          DOTNET_CLI_TELEMETRY_OPTOUT = "1";
          DOTNET_ROOT = "${pkgs.dotnet-sdk}";
        };
        shellHook = ''echo "with love from wrd :)"'';
      };
    });
  };
}
