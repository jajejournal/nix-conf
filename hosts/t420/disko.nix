# Disk layout: GPT, 1G ESP (/boot) + ext4 root (with LUKS if useLuks = true).
# install.sh replaces PUT_DISK_HERE with the disk you choose.
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
    # Manual: ls -l /dev/disk/by-id/  and put the disk here.
    device = "PUT_DISK_HERE";
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
              settings.allowDiscards = true; # TRIM on SSD
              content = rootContent;
            } else rootContent;
        };
      };
    };
  };
}
