let
  pkgsNix = import ./nix/pkgs.nix;
in
{ pkgs ? pkgsNix.native
}:
pkgs.haskell-nix.project {
  src = pkgs.haskell-nix.haskellLib.cleanGit {
    src = ./.;
    name = "cross-haskell-app";
  };
  compiler-nix-name = "ghc8105";
}
