{
  description = "Megaparsec for Lean4 Language";

  inputs = {
    lean = {
      # url = "github:leanprover/lean4/v4.0.0-m5";
      url = "github:leanprover/lean4";
    };
    yatima-std = {
      url = "github:anderssorby/YatimaStdLib.lean";
      # url = "github:yatima-inc/YatimaStdLib.lean";
      inputs.lean.follows = "lean";
    };
    straume = {
      url = "github:anderssorby/straume";
      # url = "github:yatima-inc/YatimaStdLib.lean";
      inputs.lean.follows = "lean";
      inputs.yatima-std.follows = "yatima-std";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

  };

  outputs = { self, lean, flake-utils, nixpkgs, yatima-std, straume }:
    let
      supportedSystems = [
        # "aarch64-linux"
        # "aarch64-darwin"
        # "i686-linux"
        # "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        leanPkgs = lean.packages.${system};
        pkgs = nixpkgs.legacyPackages.${system};
        project = leanPkgs.buildLeanPackage {
          deps = [ yatima-std.project.${system} ];
          debug = false;
          name = "Megaparsec";
          src = ./.;
        };
      in
      {
        inherit project;
        packages = project // {
          # inherit (leanPkgs) lean;
          # TODO
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            leanPkgs.lean-dev

            ## HLS doesn't work in VSCode, so why bother (for the time being)
            # pkgs.ghc
            # pkgs.cabal-install
            # pkgs.haskell-language-server
            # pkgs.haskellPackages.implicit-hie
            # leanPkgs.lean
          ];
        };

        defaultPackage = project;
      });
}
