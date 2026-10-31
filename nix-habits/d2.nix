{ pkgs }:
let
  # Match the playwright-go version embedded in d2 0.7.1. Its old CDN is gone.
  playwrightCore = pkgs.fetchzip {
    url = "https://registry.npmjs.org/playwright-core/-/playwright-core-1.47.2.tgz";
    sha256 = "0j21d5d7ag82g0rah736azrbcsd1jzwk6gzirjqinja5p2bhi9cc";
  };
  driver = pkgs.runCommand "d2-playwright-driver-1.47.2" { } ''
    mkdir -p "$out/ms-playwright-go/1.47.2"
    ln -s ${playwrightCore} "$out/ms-playwright-go/1.47.2/package"
  '';
in
pkgs.d2.overrideAttrs (old: {
  # Use Playwright's explicit executable option with Nix's patched Chromium.
  # Do not download upstream Linux binaries, which cannot run on NixOS.
  postPatch = (old.postPatch or "") + ''
    substituteInPlace lib/png/png.go \
      --replace-fail 'browser, err := pw.Chromium.Launch()' \
        'browser, err := pw.Chromium.Launch(playwright.BrowserTypeLaunchOptions{ExecutablePath: playwright.String("${pkgs.chromium}/bin/chromium")})' \
      --replace-fail 'Verbose:  false,' 'Verbose: false, SkipInstallBrowsers: true,'
  '';
  postInstall = old.postInstall + ''
    wrapProgram "$out/bin/d2" \
      --set PLAYWRIGHT_DRIVER_PATH ${driver} \
      --set PLAYWRIGHT_NODEJS_PATH ${pkgs.nodejs}/bin/node
  '';
})
