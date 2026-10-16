# OpenCode V2 for NixOS.
#
# nixpkgs only ships OpenCode 1.x. V2 (2.0.31) lives in the `dev` branch of the
# official `anomalyco/opencode` repo, which publishes a flake. Here we use it as
# an input (see flake.nix: inputs.opencode.url = "github:anomalyco/opencode/dev").
#
# It builds from source with bun, so the first time it takes a while.
# If you don't want OpenCode, remove ./modules/opencode.nix from the module list
# in flake.nix.
{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode
  ];
}
