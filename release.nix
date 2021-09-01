let
  pkgsNix =
    let
      # 14/07/21
      haskellNix = import (builtins.fetchTarball https://github.com/input-output-hk/haskell.nix/archive/59e14e256ef8d1ec35e083bc209d355913c4e725.tar.gz) { };

      nixpkgsSrc = haskellNix.sources.nixpkgs-2105;
      nixpkgsArgs = haskellNix.nixpkgsArgs;

      native = import nixpkgsSrc nixpkgsArgs;
      crossRpi = import nixpkgsSrc (nixpkgsArgs // {
        crossSystem = native.lib.systems.examples.raspberryPi;
      });
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
  pkgsNative = pkgsNix.native;
  pkgsRaspberryPi = pkgsNix.crossRpi;
  pkgsArmv7l = pkgsNix.crossArmv7l;

  hsApp =
    { pkgs ? pkgsNix.native
    }:
    pkgs.haskell-nix.project {
      src = pkgs.haskell-nix.haskellLib.cleanGit {
        src = ./.;
        name = "cross-haskell-app";
      };
      compiler-nix-name = "ghc8105";
    };
  appNative = hsApp { pkgs = pkgsNative; };
  appCrossRaspberryPi = hsApp { pkgs = pkgsRaspberryPi; };
  appCrossArmv7l = hsApp { pkgs = pkgsArmv7l; };

  patchForNotNixLinux = { app, name }:
    pkgsNative.runCommand "${app.name}-patched" { } ''
      set -eu
      cp ${app}/bin/${name} $out
      chmod +w $out
      ${pkgsNative.patchelf}/bin/patchelf --set-interpreter /lib/ld-linux-armhf.so.3 --set-rpath /lib:/usr/lib $out
      chmod -w $out
    '';

in
{
  native = appNative.cross-haskell-app.components.exes.cross-haskell-app-exe;

  raspberry-pi = appCrossRaspberryPi.cross-haskell-app.components.exes.cross-haskell-app-exe;
  raspberry-pi-patched = patchForNotNixLinux {
    app = appCrossRaspberryPi.cross-haskell-app.components.exes.cross-haskell-app-exe;
    name = "cross-haskell-app-exe";
  };

  armv7l = appCrossArmv7l.cross-haskell-app.components.exes.cross-haskell-app-exe;
  armv7l-patched = patchForNotNixLinux {
    app = appCrossArmv7l.cross-haskell-app.components.exes.cross-haskell-app-exe;
    name = "cross-haskell-app-exe";
  };
}
