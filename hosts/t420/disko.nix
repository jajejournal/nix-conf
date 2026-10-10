# Disco: GPT, ESP 1G (/boot) + raíz ext4 (con LUKS si useLuks = true)
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
    # Cambia 2M332LA167DJ: ls -l /dev/disk/by-id/ | grep -i ADATA
    device = "/dev/disk/by-id/ata-ADATA_SU650_2M332LA167DJ";
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
