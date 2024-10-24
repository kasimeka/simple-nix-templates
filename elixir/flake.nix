{
  nixConfig.bash-prompt-prefix = ''(elixir) '';
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; let
            my-erlang = erlang_27;
          in [
            my-erlang
            (elixir.override {erlang = my-erlang;})
            lexical
            elixir-ls
            inotify-tools # for hot reload
          ];

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

            mkdir -p .nix-mix
            mkdir -p .nix-hex
            PROJECT_ROOT="$(find-project-root)"
            export MIX_HOME="$PROJECT_ROOT/.nix-mix"
            export HEX_HOME="$PROJECT_ROOT/.nix-hex"
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
