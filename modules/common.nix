# Generic system configuration (works on ANY machine).
# Machine-specific bits live in hosts/<name>/default.nix
{ config, pkgs, lib, user, ... }:
{
  # --- Nix ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" user ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # --- Network / language ---
  # mkDefault is used so a host can override it with lib.mkForce.
  networking.networkmanager.enable = true;
  time.timeZone = lib.mkDefault "America/Bogota";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console.keyMap = lib.mkDefault "es";
  console.earlySetup = true; # Spanish keyboard for the LUKS password prompt

  # --- Power / cleanup ---
  zramSwap.enable = true;
  services.fstrim.enable = true;
  services.tlp.enable = true;
  services.udisks2.enable = true;

  # --- Audio and bluetooth ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # --- Shell and user ---
  programs.fish.enable = true;
  users.mutableUsers = true;
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "cdrom" "optical" ];
    hashedPasswordFile = "/etc/secrets/password-hash";
  };
  users.users.root.hashedPasswordFile = "/etc/secrets/password-hash"; # same as the user

  # --- Base packages ---
  environment.systemPackages = with pkgs; [ git curl wget htop pciutils usbutils ];

  system.stateVersion = "26.05";
}
