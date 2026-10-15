{ config, pkgs, lib, ... }:
let
  t = import ./theme.nix;
in
{
  # picom is managed by services.picom in desktop.nix; do not also manage the same
  # target via home.file or the module will create a conflicting managed file.
  # Note: paths are relative to this file (home/visual-files.nix), so reference
  # rofi at ../rofi_theme and nvim file in the same directory.
  home.file.".config/rofi/black_2.rasi".source = ../rofi_theme/black_2.rasi;

  xdg.configFile."nvim/after/plugin/nvim-transparency.lua".source = ./nvim-transparency.lua;

  # Ensure the font family used by rofi is available in the user environment.
  home.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
  ];
}
