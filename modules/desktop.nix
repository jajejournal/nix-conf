# Escritorio X11 (i3 + startx). Genérico: no menciona hardware concreto.
{ config, pkgs, lib, ... }:
{
  # --- X11 con startx, sin gestor de sesión ---
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

  # --- Gráficos ---
  hardware.graphics.enable = true;
  services.udev.packages = [ pkgs.brightnessctl ];

  # --- Fuentes ---
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

  # --- Integración con el escritorio (opcional pero muy útil) ---
  security.polkit.enable = true;         # diálogos de autenticación gráficos
  services.gvfs.enable = true;           # papelera y montaje en apps GTK
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
