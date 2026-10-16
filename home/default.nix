# Home-manager: usa el usuario que viene del flake (user).
{ config, pkgs, lib, user, ... }:
{
  imports = [ ./i3.nix ./polybar.nix ./terminal.nix ./desktop.nix ./nvim.nix ./apps.nix ];

  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    brightnessctl wireplumber xev
    maim xclip libnotify pavucontrol
    btop fastfetch yad clipmenu
  ];

  # startx -> ~/.xinitrc -> sesión de home-manager (~/.xsession)
  home.file.".xinitrc".text = ''
    exec "$HOME/.xsession"
  '';
  home.file."Pictures/.keep".text = "";
  xdg.configFile."shortcuts.txt".source = ./shortcuts.txt;
  home.file."Notes/.keep".text = ""; # vault de notas (Markdown)
}
