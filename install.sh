#!/usr/bin/env bash
# Install from the NixOS minimal ISO.
#   sudo loadkeys es
#   git clone https://github.com/jajejournal/nix-conf && cd nix-conf
#   sudo ./install.sh
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

HOST=t420-install
DIR=t420
# Read the username straight from flake.nix so the two never get out of sync.
USERNAME=$(sed -n 's/.*user = "\([^"]*\)".*/\1/p' flake.nix | head -n1)
[ -n "$USERNAME" ] || { echo "Could not read 'user' from flake.nix"; exit 1; }
export NIX_CONFIG="experimental-features = nix-command flakes"

[ "$(id -u)" = 0 ] || { echo "Run it with sudo."; exit 1; }

# 0) Preflight checks
command -v openssl >/dev/null || {
  echo "Missing 'openssl'. Exit the installer and run:  nix-shell -p openssl";
  exit 1;
}
if [ ! -d /sys/firmware/efi ]; then
  echo "WARNING: this machine booted in BIOS mode (no UEFI) and systemd-boot needs UEFI."
  echo "For BIOS you will have to use GRUB (see the README, 'BIOS' section)."
  read -rp "Continue anyway? (yes/no): " BIOSOK
  [ "$BIOSOK" = "yes" ] || exit 1
fi

# 1) Pick a disk (no hardcoded serials)
echo
echo "Available disks:"
ls -l /dev/disk/by-id/ | grep -E 'ata-|nvme-|mmc-|usb-' | grep -v -- '-part' || true
echo
read -rp "Paste the full disk path (e.g. /dev/disk/by-id/ata-...): " DEV
[ -b "$DEV" ] || { echo "Device does not exist: $DEV"; exit 1; }
sed -i "s|PUT_DISK_HERE|$DEV|" "hosts/$DIR/disko.nix"

# 2) Password (same for user and root). Only the hash is stored, outside git.
read -rsp "Password for '$USERNAME' and root: " P1; echo
read -rsp "Repeat the password: " P2; echo
[ "$P1" = "$P2" ] && [ -n "$P1" ] || { echo "They do not match or it is empty."; exit 1; }
HASH=$(printf '%s' "$P1" | openssl passwd -6 -stdin)

# 3) Hardware + validation BEFORE touching the disk.
nixos-generate-config --no-filesystems --show-hardware-config > "hosts/$DIR/hardware-configuration.nix"
git add -f "hosts/$DIR/hardware-configuration.nix" >/dev/null 2>&1 || true
echo "Checking that the configuration evaluates..."
nix eval --raw ".#nixosConfigurations.$HOST.config.system.build.toplevel.drvPath" >/dev/null
echo "OK."

# 4) Partition (asks for the LUKS passphrase) and mount at /mnt
read -rp "This will ERASE the whole disk $DEV. Type YES to continue: " OK
[ "$OK" = "YES" ] || exit 1
nix run github:nix-community/disko/latest -- --mode destroy,format,mount --flake ".#$HOST"

# 5) Password hash + installation
install -d -m 700 /mnt/etc/secrets
printf '%s\n' "$HASH" > /mnt/etc/secrets/password-hash
chmod 600 /mnt/etc/secrets/password-hash
nixos-install --flake ".#$HOST" --no-root-passwd

# 6) Drop the repo into the user's home
mkdir -p "/mnt/home/$USERNAME"
cp -r "$PWD" "/mnt/home/$USERNAME/nix-conf"
nixos-enter --root /mnt -c "chown -R $USERNAME:users /home/$USERNAME/nix-conf"
echo "Done. Reboot, log in as '$USERNAME' and run: startx"
