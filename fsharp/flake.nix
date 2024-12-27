{
  nixConfig.bash-prompt-prefix = ''\[\e[0;31m\](fsharp) \e[0m'';
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell {
          packages = with pkgs; [bashInteractive dotnet-sdk_8 fsautocomplete];
          env = {
            DOTNET_NOLOGO = "1";
            DOTNET_CLI_TELEMETRY_OPTOUT = "1";
            DOTNET_ROOT = "${pkgs.dotnet-sdk_8}";
          };
          shellHook = ''echo "with love from wrd :)"'';
        };
      }
    );
}
