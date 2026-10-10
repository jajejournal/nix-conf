{ config, pkgs, lib, ... }:
{
  imports = [ ./i3.nix ./polybar.nix ./terminal.nix ./desktop.nix ./nvim.nix ./apps.nix ];

  home.username = "manssell";
  home.homeDirectory = "/home/manssell";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    brightnessctl wireplumber xev
    maim xclip libnotify pavucontrol
    btop fastfetch yad
  ];

  # startx -> ~/.xinitrc -> sesión de home-manager (~/.xsession)
  home.file.".xinitrc".text = ''
    exec "$HOME/.xsession"
  '';
  home.file."Pictures/.keep".text = "";
  home.file."Notas/.keep".text = "";   # tu bóveda de notas (Markdown)
}
