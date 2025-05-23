{
  nixConfig = {
    bash-prompt-prefix = ''\[\e[0;31m\](libcosmic) \e[0m'';
  };

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [(import inputs.rust-overlay)];
        };
        rust-toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        rustPlatform = pkgs.makeRustPlatform {
          cargo = rust-toolchain;
          rustc = rust-toolchain;
        };
        drv = rustPlatform.buildRustPackage (let
          cargo-toml = pkgs.lib.importTOML ./Cargo.toml;
          pname = cargo-toml.package.name;
          version = cargo-toml.package.version;
        in {
          inherit pname version;
          src = pkgs.lib.cleanSourceWith {
            name = "${pname}-${version}-clean-src";
            src = ./.;
            filter = inputs.gitignore.lib.gitignoreFilterWith {
              basePath = ./.;
              extraRules = ''
                README.md
                LICENSE.md
                flake.*
                rust-toolchain.toml
                .gitignore
                .gitmodules
                .github
              '';
            };
          };

          useFetchCargoVendor = true;
          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "accesskit-0.16.0" = "sha256-yeBzocXxuvHmuPGMRebbsYSKSvN+8sUsmaSKlQDpW4w=";
              "atomicwrites-0.4.2" = "sha256-QZSuGPrJXh+svMeFWqAXoqZQxLq/WfIiamqvjJNVhxA=";
              "clipboard_macos-0.1.0" = "sha256-+8CGmBf1Gl9gnBDtuKtkzUE5rySebhH7Bsq/kNlJofY=";
              "cosmic-client-toolkit-0.1.0" = "sha256-7EFXDQ6aHiXq0qrjeyjqtOuC3B5JLpHQTXbPwtC+fRo=";
              "cosmic-config-0.1.0" = "sha256-g6Y9q4TDd3Pc3G3gAhtGJbOJGBo4d73ZN69k4ZGVjKs=";
              "cosmic-freedesktop-icons-0.3.0" = "sha256-XAcoKxMp1fyclalkkqVMoO7+TVekj/Tq2C9XFM9FFCk=";
              "cosmic-settings-daemon-0.1.0" = "sha256-9Pq5WFBeIRvP2VZaa3BzoqiQmzN6taa20u7k+2aF3v0=";
              "cosmic-text-0.14.2" = "sha256-Wt5ejab5EkuyGiAd9DZ1Sc8IMxDq29lwAvKnFcbhX5o=";
              "dpi-0.1.1" = "sha256-whi05/2vc3s5eAJTZ9TzVfGQ/EnfPr0S4PZZmbiYio0="; # winit
              "iced_glyphon-0.6.0" = "sha256-u1vnsOjP8npQ57NNSikotuHxpi4Mp/rV9038vAgCsfQ=";
              "smithay-clipboard-0.8.0" = "sha256-4InFXm0ahrqFrtNLeqIuE3yeOpxKZJZx+Bc0yQDtv34=";
              "softbuffer-0.4.1" = "sha256-a0bUFz6O8CWRweNt/OxTvflnPYwO5nm6vsyc/WcXyNg=";
              "taffy-0.3.11" = "sha256-SCx9GEIJjWdoNVyq+RZAGn0N71qraKZxf9ZWhvyzLaI=";
            };
          };

          nativeBuildInputs = with pkgs; [libcosmicAppHook just];
          # ++ lib.optional stdenv.isDarwin [libiconv];

          # env = {};

          dontUseJustBuild = true;
          dontUseJustCheck = true;
          justFlags = [
            "--set"
            "prefix"
            (placeholder "out")
            "--set"
            "bin-src"
            "target/${pkgs.stdenv.hostPlatform.rust.cargoShortTarget}/release/balalaika"
          ];
          # cargoBuildFlags = [];
        });
      in {
        packages.default = inputs.self.packages.${system}.balalaika;
        packages.balalaika = drv;

        devShells.default = pkgs.mkShell {
          inputsFrom = pkgs.lib.attrValues inputs.self.packages.${system};
          packages = [
            (rust-toolchain.override
              {extensions = ["rust-src" "rust-analyzer" "clippy"];})
          ];
          shellHook = ''
            echo "with löve from wrd :)"
            export LD_LIBRARY_PATH="${pkgs.wayland}/lib:${with pkgs;
              lib.makeLibraryPath
              libcosmicAppHook.depsTargetTargetPropagated}:$LD_LIBRARY_PATH"
            export XDG_DATA_DIRS="${pkgs.cosmic-icons}/share:$XDG_DATA_DIRS"
          '';
        };
      }
    );
}
