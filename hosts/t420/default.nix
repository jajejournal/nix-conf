# Solo lo específico de ESTE portátil (ThinkPad T420, gráfica Intel HD 3000).
{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix                 # generado por nixos-generate-config / install.sh
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t420
  ];

  networking.hostName = "t420";

  # --- Arranque ---
  # systemd-boot requiere UEFI. Para un equipo solo-BIOS usa GRUB (ver README).
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # --- Intel HD 3000 (VAAPI) ---
  hardware.graphics.extraPackages = [ pkgs.intel-vaapi-driver ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "i965";

  # Ejemplo para otra máquina (copia esta carpeta hosts/<nombre> y ajusta):
  #   - networking.hostName
  #   - hardware-configuration.nix
  #   - el módulo de nixos-hardware que corresponda
  #   - si no tiene batería, borra el módulo "battery" de home/polybar.nix
}
