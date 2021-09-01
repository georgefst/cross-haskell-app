let
  pkgsNix =
    let
      # 14/07/21
      haskellNix = import (builtins.fetchTarball https://github.com/input-output-hk/haskell.nix/archive/59e14e256ef8d1ec35e083bc209d355913c4e725.tar.gz) { };

      nixpkgsSrc = haskellNix.sources.nixpkgs-2105;
      nixpkgsArgs = haskellNix.nixpkgsArgs;

      native = import nixpkgsSrc nixpkgsArgs;
      crossArmv7l = import nixpkgsSrc (nixpkgsArgs // {
        crossSystem = native.lib.systems.examples.raspberryPi;
      });
    in
    {
      inherit haskellNix;

      inherit nixpkgsSrc nixpkgsArgs;

      inherit native crossRpi crossArmv7l;
    }
  ;

  hsApp = pkgs:
    pkgs.haskell-nix.project {
      src = pkgs.haskell-nix.haskellLib.cleanGit {
        src = ./.;
        name = "cross-haskell-app";
      };
      compiler-nix-name = "ghc8105";
    };
  appNative = hsApp pkgsNix.native;
  appCrossArmv7l = hsApp pkgsNix.crossArmv7l;

  patchForNotNixLinux = { app, name }:
    pkgsNix.native.runCommand "${app.name}-patched" { } ''
      set -eu
      cp ${app}/bin/${name} $out
      chmod +w $out
      ${pkgsNix.native.patchelf}/bin/patchelf --set-interpreter /lib/ld-linux-armhf.so.3 --set-rpath /lib:/usr/lib $out
      chmod -w $out
    '';

in
{
  native = appNative.cross-haskell-app.components.exes.cross-haskell-app-exe;

  armv7l = appCrossArmv7l.cross-haskell-app.components.exes.cross-haskell-app-exe;
  armv7l-patched = patchForNotNixLinux {
    app = armv7l;
    name = "cross-haskell-app-exe";
  };
}
