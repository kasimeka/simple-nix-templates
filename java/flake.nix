{
  nixConfig.bash-prompt-prefix = ''\[\e[0;31m\](java) \e[0m'';
  description = "JDK 21 env";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pname = "Henlo";

        jdk = pkgs.semeru-bin;
        jre = pkgs.semeru-jre-bin;

        pkgs = import nixpkgs {
          inherit system;
          overlays = [(_: prev: {inherit jdk;})];
        };

        drv = pkgs.stdenv.mkDerivation {
          inherit pname;
          version = "0.0.0-dev";

          src = ./src;

          buildInputs = [jdk];
          nativeBuildInputs = [
            jre
            pkgs.canonicalize-jars-hook
          ];

          buildPhase = ''find . -name '*.java' -type f -exec javac -d build/ {} +'';
          installPhase = ''
            (cd build && jar cvfe $out/opt/${pname}.jar ${pname} *)
            mkdir -p $out/bin && cat <<EOF > $out/bin/${pname}
            #!usr/bin/env sh
            JAVA_HOME=${jre} exec ${jre}/bin/java -jar $out/opt/${pname}.jar "\$@"
            EOF
            chmod +x $out/bin/${pname}
          '';
          meta.mainProgram = pname;
        };
      in {
        packages.default = drv;
        devShell = pkgs.mkShell {
          inputsFrom = [drv];
          packages = with pkgs; [
            bashInteractive
            java-language-server
          ];
          shellHook = ''echo "with love from wrd :)"'';
        };
      }
    );
}
