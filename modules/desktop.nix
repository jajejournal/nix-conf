# X11 desktop (i3 + startx). Generic: it does not mention any specific hardware.
{ config, pkgs, lib, ... }:
{
  # --- X11 with startx, no display manager ---
  services.xserver = {
    enable = true;
    xkb = {
      layout = "es,us";
      options = "caps:escape,grp:alt_shift_toggle";
    };
    displayManager.startx.enable = true;
  };
  services.libinput = {
    enable = true;
    touchpad = { tapping = true; naturalScrolling = false; };
  };

  # --- Graphics ---
  hardware.graphics.enable = true;
  services.udev.packages = [ pkgs.brightnessctl ];

  # --- Fonts ---
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    inter
    noto-fonts
    noto-fonts-color-emoji
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrainsMono Nerd Font" ];
    sansSerif = [ "Inter" ];
    emoji = [ "Noto Color Emoji" ];
  };
  programs.dconf.enable = true;
  programs.i3lock.enable = true;

  # --- Printing (USB or network) ---
  # Avahi discovers network / AirPrint printers and resolves their .local names.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # --- Spell checking: Spanish + English dictionaries ---
  # DICPATH is used by Hunspell-based apps (LibreOffice, etc.).
  environment.sessionVariables.DICPATH = lib.makeSearchPath "share/hunspell" [
    pkgs.hunspellDicts.es_ES
    pkgs.hunspellDicts.en_US
  ];
  environment.systemPackages = with pkgs; [
    system-config-printer # manage printers from a GUI
    (hunspell.withDicts (d: [ d.es_ES d.en_US ])) # dictionaries + DICPATH
    tumbler # thumbnail service for the file manager
  ];

  # --- Graphical file manager (Thunar) ---
  # programs.thunar is a NixOS module (home-manager has no Thunar module).
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [ thunar-volman thunar-archive-plugin ];
  };

  # --- Phone integration (KDE Connect: files, clipboard, notifications) ---
  programs.kdeconnect.enable = true;

  # --- Desktop integration (optional but very useful) ---
  security.polkit.enable = true;         # graphical authentication dialogs
  services.gvfs.enable = true;           # trash and mounting in GTK apps
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
