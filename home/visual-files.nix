{ config, pkgs, lib, ... }:
{
  # picom is managed by services.picom in desktop.nix; do not also manage the same
  # target via home.file or the module will create a conflicting managed file.
  home.file.".config/rofi/black_2.rasi".source = ./rofi_theme/black_2.rasi;

  xdg.configFile."nvim/after/plugin/nvim-transparency.lua".source = ./home/nvim-transparency.lua;

  # Ensure the font family used by rofi is available in the user environment.
  home.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
  ];
}
