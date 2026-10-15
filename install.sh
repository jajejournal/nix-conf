#!/usr/bin/env bash
# Usage (from minimal ISO, network already available):  sudo loadkeys es; git clone ...; cd nix-conf; sudo ./install.sh
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
HOST=t420-install
DIR=t420
export NIX_CONFIG="experimental-features = nix-command flakes"

[ "$(id -u)" = 0 ] || { echo "Run with sudo."; exit 1; }
if grep -q PONER_SERIAL hosts/$DIR/disko.nix; then
  echo "Edit hosts/$DIR/disko.nix and replace PONER_SERIAL with the current serial:"
  echo "  ls -l /dev/disk/by-id/ | grep -i ADATA"
  exit 1
fi

# 1) Password (same for manssell and root). Only the hash is stored, outside git.
read -rsp "Password for user 'manssell' and root: " P1; echo
read -rsp "Repeat Password: " P2; echo
[ "$P1" = "$P2" ] && [ -n "$P1" ] || { echo "Passwords do not match or are empty."; exit 1; }
HASH=$(printf '%s' "$P1" | openssl passwd -6 -stdin)

# 2) Hardware + validation before touching the disk.
nixos-generate-config --no-filesystems --show-hardware-config > hosts/$DIR/hardware-configuration.nix
git add -f hosts/$DIR/hardware-configuration.nix
echo "Checking that the configuration evaluates..."
nix eval --raw .#nixosConfigurations.$HOST.config.system.build.toplevel.drvPath >/dev/null
echo "OK."

# 3) Partition (will be prompted for the LUKS passphrase) and mount at /mnt
read -rp "This will erase the entire disk. Type YES to continue: " OK
[ "$OK" = "YES" ] || exit 1
nix run github:nix-community/disko/latest -- --mode destroy,format,mount --flake .#$HOST

# 4) Password hash + installation
install -d -m 700 /mnt/etc/secrets
printf '%s\n' "$HASH" > /mnt/etc/secrets/password-hash
chmod 600 /mnt/etc/secrets/password-hash
nixos-install --flake .#$HOST --no-root-passwd

# 5) Leave the repo in the home directory
mkdir -p /mnt/home/manssell
cp -r "$PWD" /mnt/home/manssell/nix-conf
nixos-enter --root /mnt -c 'chown -R manssell:users /home/manssell/nix-conf'
echo "Done. Reboot, log in as 'manssell', then run: startx"
