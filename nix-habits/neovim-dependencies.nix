{ pkgs, ... }:

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

    # Mason installers and language-server runtimes.
    go
    nodejs
    # Current JDTLS bundles require Java 25.
    jdk25
    (python3.withPackages (ps: with ps; [ pip pynvim pylatexenc ]))
    rustc
    cargo
    flutter

    # Markdown images, diagram renderers, and the X11 clipboard.
    imagemagick
    mermaid-cli
    plantuml
    (import ./d2.nix { inherit pkgs; })
    gnuplot
    xclip

    # Agentic's configured ACP provider, pinned to an upstream release.
    (callPackage ./omp.nix {})
  ];
}
