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
    };
  };
}
