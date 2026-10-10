{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix # copiado de /etc/nixos (o generado por install.sh)
  ];

  # --- Arranque ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # --- Sistema ---
  networking.hostName = "t420";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "es_CO.UTF-8";
  console.keyMap = "es";
  console.earlySetup = true; # teclado es en la clave de LUKS

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 14d"; };

  zramSwap.enable = true;
  services.fstrim.enable = true;
  services.tlp.enable = true;

  # --- Usuarios (contraseña: hash en /etc/secrets, lo crea install.sh) ---
  programs.fish.enable = true;
  users.mutableUsers = true;
  users.users.manssell = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "cdrom" "optical" ];
    hashedPasswordFile = "/etc/secrets/password-hash";
  };
  users.users.root.hashedPasswordFile = "/etc/secrets/password-hash"; # misma que manssell

  # --- Gráficos / X11 (HD 3000) con startx, sin display manager ---
  services.xserver = {
    enable = true;
    xkb = { layout = "es,us"; options = "caps:escape,grp:alt_shift_toggle"; };
    displayManager.startx.enable = true;
  };
  services.libinput = {
    enable = true;
    touchpad = { tapping = true; naturalScrolling = false; };
  };

  # --- Audio y teclas físicas ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  services.udev.packages = [ pkgs.brightnessctl ];

  hardware.graphics = { enable = true; extraPackages = [ pkgs.intel-vaapi-driver ]; };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "i965";

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.udisks2.enable = true;


  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono inter noto-fonts noto-fonts-color-emoji ];
  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrainsMono Nerd Font" ];
    sansSerif = [ "Inter" ];
    emoji = [ "Noto Color Emoji" ];
  };
  programs.dconf.enable = true;
  programs.i3lock.enable = true;

  environment.systemPackages = with pkgs; [ git curl wget htop pciutils usbutils ];

  system.stateVersion = "26.05";
}
