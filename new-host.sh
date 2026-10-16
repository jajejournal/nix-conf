#!/usr/bin/env bash
# Create (or refresh) a machine folder in hosts/, from templates/host/.
# Use it on an already-installed system to add that machine, then rebuild.
#   sudo ./new-host.sh <machine-name>
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

NAME="${1:-}"
[ -n "$NAME" ] || { echo "Usage: ./new-host.sh <machine-name>"; exit 1; }
DIR="hosts/$NAME"

if [ -d "$DIR" ]; then
  echo "hosts/$NAME already exists; refreshing its hardware-configuration.nix."
else
  echo "Creating $DIR ..."
  mkdir -p "$DIR"
  cp templates/host/default.nix "$DIR/default.nix"
  cp templates/host/disko.nix   "$DIR/disko.nix"
  sed -i "s/HOSTNAME_PLACEHOLDER/$NAME/" "$DIR/default.nix"
fi

echo "Detecting hardware -> $DIR/hardware-configuration.nix"
nixos-generate-config --no-filesystems --show-hardware-config > "$DIR/hardware-configuration.nix"

# Flakes only see files tracked by git.
git add -f "$DIR" >/dev/null 2>&1 || true

echo
echo "Done. Machine '$NAME' is ready."
echo "Next:"
echo "  - fresh install from the ISO:   sudo ./install.sh $NAME"
echo "  - already installed system:      sudo nixos-rebuild switch --flake .#$NAME"
