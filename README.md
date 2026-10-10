# nix-conf (ThinkPad T420)
NixOS 26.05 · flakes · home-manager · disko · i3 + startx.

Instalar: ISO minimal → `sudo loadkeys es` → red → `git clone https://github.com/jajejournal/nix-conf` →
editar `hosts/t420/disko.nix` (serial del disco) → `sudo ./install.sh`.
Después: `sudo nixos-rebuild switch --flake ~/nix-conf#t420`.
La contraseña NO está en el repo: vive como hash en `/etc/secrets/password-hash`.

## Ya tengo NixOS instalado (sin borrar nada)
    nix-shell -p git openssl
    git clone https://github.com/jajejournal/nix-conf && cd nix-conf
    cp /etc/nixos/hardware-configuration.nix hosts/t420/ && git add -f hosts/t420/hardware-configuration.nix
    sudo mkdir -p /etc/secrets && openssl passwd -6 | sudo tee /etc/secrets/password-hash >/dev/null
    sudo chmod 600 /etc/secrets/password-hash
    sudo nixos-rebuild switch --flake .#t420
