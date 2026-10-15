{ config, pkgs, lib, ... }:
let
  t = import ./theme.nix;
in
{
  # Keep the same home-manager behaviour, but ensure the visual files are installed
  # in the expected config paths for the current user.
  home.file.".config/picom/picom.conf".source = ./picom/picom.conf;
  home.file.".config/rofi/black_2.rasi".source = ./rofi_theme/black_2.rasi;

  xdg.configFile."nvim/after/plugin/nvim-transparency.lua".source = ./home/nvim-transparency.lua;

  # Ensure the font family used by rofi is available in the user environment.
  home.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
  ];
}
