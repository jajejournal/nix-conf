#!/usr/bin/env bash
# Instalación desde el ISO mínimo de NixOS.
#   sudo loadkeys es
#   git clone https://github.com/jajejournal/nix-conf && cd nix-conf
#   sudo ./install.sh
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

HOST=t420-install
DIR=t420
# Toma el usuario directamente del flake.nix para que no se desincronicen.
USERNAME=$(sed -n 's/.*user = "\([^"]*\)".*/\1/p' flake.nix | head -n1)
[ -n "$USERNAME" ] || { echo "No pude leer 'user' de flake.nix"; exit 1; }
export NIX_CONFIG="experimental-features = nix-command flakes"

[ "$(id -u)" = 0 ] || { echo "Ejecuta con sudo."; exit 1; }

# 0) Comprobaciones previas
command -v openssl >/dev/null || {
  echo "Falta 'openssl'. Sal del instalador y ejecuta:  nix-shell -p openssl";
  exit 1;
}
if [ ! -d /sys/firmware/efi ]; then
  echo "AVISO: el equipo arrancó en modo BIOS (no UEFI) y systemd-boot necesita UEFI."
  echo "Para BIOS tendrás que usar GRUB (mira el README, sección 'BIOS')."
  read -rp "¿Continuar de todos modos? (yes/no): " BIOSOK
  [ "$BIOSOK" = "yes" ] || exit 1
fi

# 1) Elección de disco (nada de seriales hardcodeados)
echo
echo "Discos disponibles:"
ls -l /dev/disk/by-id/ | grep -E 'ata-|nvme-|mmc-|usb-' | grep -v -- '-part' || true
echo
read -rp "Pega la ruta completa del disco (ej: /dev/disk/by-id/ata-...): " DEV
[ -b "$DEV" ] || { echo "No existe el dispositivo: $DEV"; exit 1; }
sed -i "s|PONER_DISCO|$DEV|" "hosts/$DIR/disko.nix"

# 2) Contraseña (igual para usuario y root). Solo se guarda el hash, fuera de git.
read -rsp "Contraseña para '$USERNAME' y root: " P1; echo
read -rsp "Repite la contraseña: " P2; echo
[ "$P1" = "$P2" ] && [ -n "$P1" ] || { echo "No coinciden o está vacía."; exit 1; }
HASH=$(printf '%s' "$P1" | openssl passwd -6 -stdin)

# 3) Hardware + validación ANTES de tocar el disco.
nixos-generate-config --no-filesystems --show-hardware-config > "hosts/$DIR/hardware-configuration.nix"
git add -f "hosts/$DIR/hardware-configuration.nix" >/dev/null 2>&1 || true
echo "Comprobando que la configuración evalúa..."
nix eval --raw ".#nixosConfigurations.$HOST.config.system.build.toplevel.drvPath" >/dev/null
echo "OK."

# 4) Particionar (pide la passphrase de LUKS) y montar en /mnt
read -rp "Esto BORRARÁ TODO el disco $DEV. Escribe YES para continuar: " OK
[ "$OK" = "YES" ] || exit 1
nix run github:nix-community/disko/latest -- --mode destroy,format,mount --flake ".#$HOST"

# 5) Hash de contraseña + instalación
install -d -m 700 /mnt/etc/secrets
printf '%s\n' "$HASH" > /mnt/etc/secrets/password-hash
chmod 600 /mnt/etc/secrets/password-hash
nixos-install --flake ".#$HOST" --no-root-passwd

# 6) Deja el repo en el home del usuario
mkdir -p "/mnt/home/$USERNAME"
cp -r "$PWD" "/mnt/home/$USERNAME/nix-conf"
nixos-enter --root /mnt -c "chown -R $USERNAME:users /home/$USERNAME/nix-conf"
echo "Listo. Reinicia, entra como '$USERNAME' y ejecuta: startx"
