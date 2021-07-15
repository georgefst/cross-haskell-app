let
  pkgsNix = import ./nix/pkgs.nix;
  pkgsRaspberryPi = pkgsNix.crossRpi;

  hsApp = import ./default.nix;
  appCrossRaspberryPi = hsApp { pkgs = pkgsRaspberryPi; };
in
{
  raspberry-pi = appCrossRaspberryPi.cross-haskell-app.components.exes.cross-haskell-app-exe;
}
