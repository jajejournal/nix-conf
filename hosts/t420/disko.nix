# Layout de disco: GPT, ESP 1G (/boot) + raíz ext4 (con LUKS si useLuks = true).
# install.sh sustituye PONER_DISCO por el disco que elijas.
{ lib, ... }:
let
  useLuks = true;
  rootContent = {
    type = "filesystem";
    format = "ext4";
    mountpoint = "/";
    mountOptions = [ "noatime" ];
  };
in
{
  disko.devices.disk.main = {
    type = "disk";
    # Manual: ls -l /dev/disk/by-id/  y pon aquí el disco.
    device = "PONER_DISCO";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content =
            if useLuks then {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true; # TRIM en SSD
              content = rootContent;
            } else rootContent;
        };
      };
    };
  };
}
