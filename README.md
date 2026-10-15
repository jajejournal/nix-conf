# nix-conf (ThinkPad T420)
NixOS 26.05 · flakes · home-manager · disko · i3 + startx.

Install: minimal ISO → `sudo loadkeys es` → network → `git clone https://github.com/jajejournal/nix-conf` →
edit `hosts/t420/disko.nix` (disk serial) → `sudo ./install.sh`.
Afterwards: `sudo nixos-rebuild switch --flake ~/nix-conf#t420`.
The password is NOT in the repo: it is stored as a hash in `/etc/secrets/password-hash`.

## I already have NixOS installed (without wiping anything)
    nix-shell -p git openssl
    git clone https://github.com/jajejournal/nix-conf && cd nix-conf
    cp /etc/nixos/hardware-configuration.nix hosts/t420/ && git add -f hosts/t420/hardware-configuration.nix
    sudo mkdir -p /etc/secrets && openssl passwd -6 | sudo tee /etc/secrets/password-hash >/dev/null
    sudo chmod 600 /etc/secrets/password-hash
    sudo nixos-rebuild switch --flake .#t420
