# Configuración genérica del sistema (sirve para CUALQUIER máquina).
# Lo específico de cada portátil va en hosts/<nombre>/default.nix
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

  # --- Red / idioma ---
  # Usa mkDefault para poder sobreescribirlo desde el host con lib.mkForce.
  networking.networkmanager.enable = true;
  time.timeZone = lib.mkDefault "America/Bogota";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console.keyMap = lib.mkDefault "es";
  console.earlySetup = true; # teclado es para la contraseña de LUKS

  # --- Energía / limpieza ---
  zramSwap.enable = true;
  services.fstrim.enable = true;
  services.tlp.enable = true;
  services.udisks2.enable = true;

  # --- Audio y bluetooth ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # --- Shell y usuario ---
  programs.fish.enable = true;
  users.mutableUsers = true;
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "cdrom" "optical" ];
    hashedPasswordFile = "/etc/secrets/password-hash";
  };
  users.users.root.hashedPasswordFile = "/etc/secrets/password-hash"; # misma que el usuario

  # --- Paquetes base ---
  environment.systemPackages = with pkgs; [ git curl wget htop pciutils usbutils ];

  system.stateVersion = "26.05";
}
