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
