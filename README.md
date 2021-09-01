# cross-haskell-app

Just a simple example of cross-compilation for Raspberry Pi using Nix.

## Commands

- `nix-build release.nix -A native`: builds the Haskell application for the current platform (with Nix).
- `nix-build release.nix -A arm` builds the Haskell application for armv7l Raspberry Pi (with Nix).

## Execution

For the native executable: `./result/bin/cross-haskell-app-exe`

For the cross-compiled executable, qemu can be used. For example: `qemu-arm ./result/bin/cross-haskell-app-exe`
