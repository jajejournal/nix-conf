# OpenCode V2 para NixOS.
#
# nixpkgs solo trae OpenCode 1.x. La V2 (2.0.31) vive en la rama `dev` del
# repo oficial `anomalyco/opencode`, que publica un flake. Aquí la usamos como
# input (ver flake.nix: inputs.opencode.url = "github:anomalyco/opencode/dev").
#
# Se compila desde fuente con bun, así que la primera vez tarda.
# Si no quieres OpenCode, borra ./modules/opencode.nix de la lista de modules
# en flake.nix.
{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode
  ];
}
