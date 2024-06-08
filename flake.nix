{
  description = "A set of very simple flake templates";
  outputs = _: {
    templates = {
      go = {
        path = ./go;
        description = "a go modules project with an lsp, a debugger and vscode config";
        welcomeText = ''
          # welcome to your new go project =)

          - you can compile and run the project with `nix run .`
          - you can get in the dev environment with `nix develop .`
          - to rename the project, update the `go.mod` file and the `pname` variable in `flake.nix`

          inside the dev environment:

          - run `godoc -http :8080` to start a local docs server
          - run `GOMOD=$PWD/go.mod go install golang.org/x/website/tour@latest` to install the go tour
            then run `tour` to start the tour server
          - open the project in vscode & install the Go extension to start using the language server, debugger
            and formatter
          - create a Makefile to run common tasks if needed.
        '';
      };

      java = {
        path = ./java;
        description = "a java project with no package manager or build system :3";
        welcomeText = ''
          # welcome to your new java project =)

          - you can compile and run the project with `nix run .`
          - you can get in the dev environment with `nix develop .`
          - to rename the project:
            - move `./src/Henlo.java` to `./src/YourNewClassName.java`
            - update the main class's name in `./src/YourNewClassName.java` to match the new filename
            - update the `mainClass` field in `./.vscode/launch.json`
            - update the `pname` variable in `flake.nix`

          inside the dev environment:

          - open the project in VSCode & install the "Debugger for Java" and "Language Support for Java(TM)
            by Red Hat" extensions to start using the language server, debugger and formatter
        '';
      };

      fsharp = {
        path = ./fsharp;
        welcomeText = ''
          # welcome to your new fsharp project =)

          - you can create a new simple project by running `dotnet new console --lang f#`
            inside the dev environment started by `nix develop .`
        '';
      };

      csharp = {
        path = ./csharp;
        welcomeText = ''
          # welcome to your new csharp project =)

          - you can create a new simple project by running `dotnet new console` inside
            the dev environment started by `nix develop .`
        '';
      };
    };
  };
}
