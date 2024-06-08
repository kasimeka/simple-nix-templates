{
  nixConfig.bash-prompt-prefix = ''\[\e[0;31m\](csharp) \e[0m'';
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        csharpier = let
          dotnet-sdk_6 = pkgs.dotnet-sdk;
        in
          pkgs.symlinkJoin {
            name = "csharpier-rewrapped";
            paths = [pkgs.csharpier];
            buildInputs = [pkgs.makeWrapper];
            postBuild = ''
              rm $out/bin/dotnet-csharpier
              makeWrapper \
                $out/lib/csharpier/dotnet-csharpier \
                $out/bin/dotnet-csharpier \
                --set DOTNET_ROOT ${dotnet-sdk_6} \
                --set PATH ${pkgs.lib.makeBinPath [dotnet-sdk_6]} \
                --prefix LD_LIBRARY_PATH ${pkgs.lib.makeLibraryPath [pkgs.icu]}

              ln -s $out/bin/{dotnet-csharpier,csharpier}
            '';

            meta.mainProgram = "dotnet-csharpier";
          };
      in {
        packages.default = csharpier;
        devShell = pkgs.mkShell {
          packages =
            [csharpier]
            ++ (with pkgs; [
              bashInteractive
              dotnet-sdk_8
              # csharp-ls # uncomment for neovim :)
            ]);
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
