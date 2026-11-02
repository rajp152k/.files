{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "omp";
  version = "18.14.0";

  src = fetchurl {
    name = "omp-linux-x64-${version}";
    url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
    hash = "sha256-590rYGxOvp0ae8+tG4gg25aM1rBUCf7RxryNsLapWo8=";
  };

  dontUnpack = true;
  dontBuild = true;
  # Preserve Bun's embedded payload; the system module enables nix-ld.
  dontFixup = true;

  installPhase = ''
    install -Dm755 "$src" "$out/bin/omp"
  '';

  meta = {
    description = "Oh My Pi ACP server and terminal coding agent";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = [ "x86_64-linux" ];
  };
}
