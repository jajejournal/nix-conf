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

  # --- Desktop integration (optional but very useful) ---
  security.polkit.enable = true;         # graphical authentication dialogs
  services.gvfs.enable = true;           # trash and mounting in GTK apps
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
