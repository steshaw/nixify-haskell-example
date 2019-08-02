let
  #
  # Look here for information about how to generate `nixpkgs-version.json`.
  #  → https://nixos.wiki/wiki/FAQ/Pinning_Nixpkgs
  #
  pinnedVersion = builtins.fromJSON (builtins.readFile ./.nixpkgs-version.json);
  pinnedPkgs = import (builtins.fetchGit {
    inherit (pinnedVersion) url rev;

    ref = "nixos-unstable";
  }) {};
in
{ pkgs ? pinnedPkgs }:
with pkgs; mkShell {
  buildInputs = [
    direnv
    emacs
    haskell.compiler.ghc865
    haskellPackages.brittany
    haskellPackages.hindent
    haskellPackages.hlint
    haskellPackages.hoogle
    openssl
    pkgconfig
    postgresql_11
    shellcheck
    stack
    vim
    zlib
  ];

  shellHook = ''
    source .local/etc/environment
  '';
}
