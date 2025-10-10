{
  nixConfig.bash-prompt-prefix = ''(java) '';

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
      mainClass = "Henlo";
    in
      {
        stdenv,
        jdk,
        jre ? jre_minimal,
        stripJavaArchivesHook,
        jre_minimal ? null,
      }:
        stdenv.mkDerivation {
          inherit pname version;
          src = ./src;

          buildInputs = [jre];
          nativeBuildInputs = [jdk stripJavaArchivesHook];

          buildPhase = ''find . -name '*.java' -type f -exec javac -d build/ {} +'';
          installPhase = ''
            (cd build && jar cvfe $out/share/java/${pname}.jar ${mainClass} *)
            mkdir -p $out/bin && cat <<EOF > $out/bin/${pname}
            #!usr/bin/env sh
            JAVA_HOME=${jre} exec ${jre}/bin/java -jar $out/share/java/${pname}.jar "\$@"
            EOF
            chmod +x $out/bin/${pname}
          '';
          meta.mainProgram = pname;
        };
  in {
    packages = forAllSystems (pkgs: {default = pkgs.callPackage drv {};});
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        inputsFrom = [drv];
        packages = with pkgs; [
          bashInteractive
          checkstyle
          # uncomment for neovim :)
          /*
          google-java-format
          (java-language-server.overrideMavenAttrs (_: {
            buildOffline = true;
            mvnHash = "sha256-kSoWd3r37bK/MYG8FKj6Kj3Z2wlHrSsDv3NdxbvhsaA=";
            src = fetchFromGitHub {
              owner = "nya3jp";
              repo = "java-language-server";
              rev = "0b256dfbe5e126112a90b70537b46b4813be6b93";
              hash = "sha256-6lIEavMxuIaxT6WjlYinP4crSyyVuMMtsUHXuVhvBRM=";
            };
          }))
          */
        ];
        shellHook = ''echo "with love from wrd :)"'';
      };
    });
  };
}
