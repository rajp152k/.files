{ pkgs, ... }:

let
  # The Lisp backends load SQLite and OpenSSL through CFFI.
  sbclForNeovim = pkgs.symlinkJoin {
    name = "sbcl-neovim";
    paths = [ pkgs.sbcl ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/sbcl" \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.sqlite pkgs.openssl ]}
    '';
  };
in

{
  # Mason downloads generic Linux binaries rather than Nix-built executables.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ icu libuuid ];
  };

  # rust-analyzer uses the matching standard-library source for navigation.
  environment.variables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

  environment.systemPackages = with pkgs; [
    # Treesitter parsers and Telescope's native fuzzy finder.
    gcc
    gnumake
    unzip
    git
    curl
    gnutar
    gzip
    tree-sitter

    # Project search and the persistent Lisp console launcher.
    ripgrep
    fd
    tmux
    perl

    # Mason installers and language-server runtimes.
    go
    nodejs
    # Current JDTLS bundles require Java 25.
    jdk25
    (python3.withPackages (ps: with ps; [ pip pynvim pylatexenc ipython ]))
    rustc
    cargo
    flutter

    # Interactive Common Lisp and Clojure development.
    sbclForNeovim
    clojure
    clojure-lsp
    # Conjure's default auto-REPL runs `bb nrepl-server`.
    babashka

    # Markdown images, diagram renderers, and the X11 clipboard.
    imagemagick
    mermaid-cli
    plantuml
    (import ./d2.nix { inherit pkgs; })
    gnuplot
    xclip

    # Standalone OMP; Agentic uses Autolith from the existing user profile.
    (callPackage ./omp.nix {})
  ];
}
