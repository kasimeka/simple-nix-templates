{
  nixConfig.bash-prompt-prefix = ''(elixir) '';
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        beamPkgs = pkgs.beamMinimal28Packages;
      in {
        devShells.default = pkgs.mkShell {
          packages =
            (with beamPkgs; [erlang elixir_1_19])
            ++ (with pkgs;
              [lexical elixir-ls]
              ++ lib.optionals stdenv.isLinux [inotify-tools]);

          shellHook = ''
            find-project-root () {
              local path="$PWD"
              while [[ "$path" != "" && ! -e "$path/mix.exs" && ! -e "$path/.git" ]]; do
                path=''${path%/*}
              done
              [[ "$path" == "" ]] && {
                >&2 echo "Couldn't find project root, falling back to \$PWD"
                echo "$PWD"
                return
              }
              echo "$path"
            }

            PROJECT_ROOT="$(find-project-root)"
            export MIX_HOME="$PROJECT_ROOT/.nix-mix"
            export HEX_HOME="$PROJECT_ROOT/.nix-hex"
            mkdir -p "$MIX_HOME"
            mkdir -p "$HEX_HOME"
            export PATH="$MIX_HOME/bin:$HEX_HOME/bin:$PATH"
            export LANG=en_US.UTF-8
            export ERL_AFLAGS="-kernel shell_history enabled"

            [ ! -e "$PROJECT_ROOT"/.mix_complete.cache ] && {
              mix deps.get && mix complete.bash &>/dev/null
              . <(
                mix complete.bash ||
                  >&2 echo 'echo "\`mix complete.bash\` failed"'
              )
            }
          '';
        };
      }
    );
}
