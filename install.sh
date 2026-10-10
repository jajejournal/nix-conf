#!/usr/bin/env bash
# Uso (desde el ISO minimal, ya con red):  sudo loadkeys es; git clone ...; cd nix-conf; sudo ./install.sh
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
HOST=t420-install
DIR=t420
export NIX_CONFIG="experimental-features = nix-command flakes"

[ "$(id -u)" = 0 ] || { echo "Ejecuta con sudo."; exit 1; }
if grep -q PONER_SERIAL hosts/$DIR/disko.nix; then
  echo "Edita hosts/$DIR/disko.nix y cambia PONER_SERIAL por el real:"
  echo "  ls -l /dev/disk/by-id/ | grep -i ADATA"
  exit 1
fi

# 1) Contraseña (misma para manssell y root). Solo se guarda el hash, fuera de git.
read -rsp "Contraseña para manssell y root: " P1; echo
read -rsp "Repite: " P2; echo
[ "$P1" = "$P2" ] && [ -n "$P1" ] || { echo "No coinciden o está vacía."; exit 1; }
HASH=$(printf '%s' "$P1" | openssl passwd -6 -stdin)

# 2) Hardware + comprobación ANTES de tocar el disco
nixos-generate-config --no-filesystems --show-hardware-config > hosts/$DIR/hardware-configuration.nix
git add -f hosts/$DIR/hardware-configuration.nix
echo "Comprobando que la configuración evalúa..."
nix eval --raw .#nixosConfigurations.$HOST.config.system.build.toplevel.drvPath >/dev/null
echo "OK."

# 3) Particionar (pedirá la clave de LUKS) y montar en /mnt
read -rp "ESTO BORRA TODO EL DISCO. Escribe SI para continuar: " OK
[ "$OK" = "SI" ] || exit 1
nix run github:nix-community/disko/latest -- --mode destroy,format,mount --flake .#$HOST

# 4) Hash de contraseña + instalación
install -d -m 700 /mnt/etc/secrets
printf '%s\n' "$HASH" > /mnt/etc/secrets/password-hash
chmod 600 /mnt/etc/secrets/password-hash
nixos-install --flake .#$HOST --no-root-passwd

# 5) Dejar el repo en tu home
mkdir -p /mnt/home/manssell
cp -r "$PWD" /mnt/home/manssell/nix-conf
nixos-enter --root /mnt -c 'chown -R manssell:users /home/manssell/nix-conf'
echo "Listo. reboot, entra con manssell y escribe: startx"
