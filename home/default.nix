{ config, pkgs, lib, ... }:
{
  imports = [ ./i3.nix ./polybar.nix ./terminal.nix ./desktop.nix ./nvim.nix ./apps.nix ./visual-files.nix ];

  home.username = "manssell";
  home.homeDirectory = "/home/manssell";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    brightnessctl wireplumber xev
    maim xclip libnotify pavucontrol
    btop fastfetch yad
  ];

  # startx -> ~/.xinitrc -> home-manager session (~/.xsession)
  home.file.".xinitrc".text = ''
    exec "$HOME/.xsession"
  '';
  home.file."Pictures/.keep".text = "";
  xdg.configFile."shortcuts.txt".source = ./shortcuts.txt;
  home.file."Notes/.keep".text = "";   # Notes vault (Markdown)
}
