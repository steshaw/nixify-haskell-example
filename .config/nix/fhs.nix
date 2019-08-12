#
# When using Nix, all building (including using Overmind) must happen in a FHS.
#
# Invoke with:
#
#  $ nix-shell --pure .local/etc/nix/fhs.nix
#
# or simply:
#
#  $ fhs
#
# Invoke a particular command (e.g. overmind start) with:
#
#  $ nix-shell --pure .local/etc/nix/fhs.nix --argstr run 'stack test'
#
# or simply:
#
#  $ fhs stack test
#
let
  # See https://nixos.wiki/wiki/FAQ/Pinning_Nixpkgs.
  pinnedVersion = builtins.fromJSON (builtins.readFile ./.nixpkgs-version.json);
  pinnedPkgs = import (builtins.fetchGit {
    inherit (pinnedVersion) url rev;

    ref = "nixos-unstable";
  }) {};
in {
  # Can override pkgs with `--arg pkgs ...`.
  pkgs ? pinnedPkgs,
  # This allows us to provide a command to run via `--argstr run COMMAND`.
  run ? "bash"
}:
with pkgs;
let
  node_ = nodejs-10_x;
  yarn_ = (yarn.override { nodejs = node_; });
in (buildFHSUserEnv {
  name = "fhs";
  targetPkgs = pkgs: with pkgs; [
    #
    # Build dependencies.
    #
    haskell.compiler.ghc865
    haskellPackages.stack

    binutils
    iana-etc
    ncurses
#    openssh
#    openssl # XXX: Can we prefer libressl?
#    perl
#    phantomjs2
    pkgconfig
    postgresql_11
#    yarn_
    zlib.dev

#    sqitchPg
#    watchman

    # Shell utilities.
    git
    neovim
    overmind
    ripgrep
    which
    zsh
  ];
  runScript = "${run}";
  profile = ''
    echo "buildFHSUserEnv: runScript = \"${run}\"" >&2

    echo "buildFHSUserEnv: Stack version is $(stack --version)" >&2
    echo "buildFHSUserEnv: Bash version is $BASH_VERSION" >&2

    source .local/etc/environment
    export GIT_SSL_CAINFO=~/.nix-profile/etc/ssl/certs/ca-bundle.crt
    export LANG=C.UTF-8

    PS1="\n$PS1\n\$ "
  '';
}).env
