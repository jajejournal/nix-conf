# nix-conf

My NixOS 26.05 setup: **flakes + home-manager + disko**, with an **i3** desktop on X11 (started with `startx`, no display manager). Pure black theme with Material Ocean accents. Shared config lives in `modules/`; per-machine bits in `hosts/<name>/`, so it can run on more than one laptop.

## Screenshots

  <table>
    <!-- Primera fila: 3 capturas -->
    <tr>
      <td width="33%"><img src="assets/terminal.png" alt="Terminal"></td>
      <td width="33%"><img src="assets/browser.png" alt="Browser"></td>
      <td width="33%"><img src="assets/neovim.png" alt="Code (neovim)"></td>
    </tr>
    <!-- Segunda fila: 2 capturas centradas -->
    <tr>
      <td width="33%"><img src="assets/files.png" alt="Files"></td>
      <td width="33%"><img src="assets/zathura.png" alt="PDF reader"></td>
    </tr>
  </table>

## Overview

| Area | What I use |
| --- | --- |
| Window manager | i3 (gaps, vim-style keys) |
| Bar | polybar (top), clickable modules |
| Terminal / shell | alacritty, fish, starship, zoxide, fzf, eza, bat |
| Launcher / notifications | rofi, dunst |
| Compositor | picom |
| Editor | Neovim: LSP, completion, format on save (conform), diagnostics panel (trouble), start screen (alpha) |
| Notes | Neovim + obsidian.nvim, vault in `~/Notes` |
| Files / media | yazi, zathura, mpv, imv, cmus |
| Browser | Firefox (declarative profile) |
| Theme | JetBrainsMono Nerd Font + Inter, colors from `home/theme.nix` |
| Disk | disko: GPT, 1 GB ESP + ext4 root (LUKS optional) |

Press **Super + ç** at any time to open the shortcuts cheatsheet (`home/shortcuts.txt`).

## Repository layout

```
nix-conf/
├── flake.nix                  # user + hosts
├── install.sh                 # fresh install: disk picker + disko + nixos-install
├── modules/                   # generic (works on any machine)
│   ├── common.nix             # network, audio, bluetooth, nix, user
│   ├── desktop.nix            # X11 + i3 + fonts + polkit/portal
│   └── opencode.nix           # OpenCode V2 (disabled by default)
├── hosts/<name>/              # per-machine only
│   ├── default.nix            # hostname, boot loader, GPU
│   ├── disko.nix              # disk layout (device = PONER_DISCO)
│   └── hardware-configuration.nix
├── home/
│   ├── default.nix
│   ├── theme.nix
│   ├── i3.nix  polybar.nix
│   ├── nvim.nix  nvim.lua
│   └── shortcuts.txt
└── assets/
    └── screenshots...

```

## Flake outputs

| Output | Use |
| --- | --- |
| `.#t420` | An already installed NixOS system (daily use) |
| `.#t420-install` | Fresh install with disko, used by `install.sh` |

## Installation

### Option A: NixOS is already installed (nothing is wiped)

```sh
nix-shell -p git openssl
git clone https://github.com/jajejournal/nix-conf && cd nix-conf

# Reuse this machine's hardware config
cp /etc/nixos/hardware-configuration.nix hosts/t420/
git add -f hosts/t420/hardware-configuration.nix

# Password hash (never stored in the repo)
sudo mkdir -p /etc/secrets
openssl passwd -6 | sudo tee /etc/secrets/password-hash >/dev/null
sudo chmod 600 /etc/secrets/password-hash

sudo nixos-rebuild switch --flake .#t420
```

### Option B: fresh install from the minimal ISO (erases the whole disk)

1. Boot the NixOS minimal ISO, then `sudo loadkeys es` and connect to the network.
2. `git clone https://github.com/jajejournal/nix-conf && cd nix-conf`
3. In `hosts/t420/disko.nix`, set `device` to your disk (`ls -l /dev/disk/by-id/`).
4. `sudo ./install.sh`

The script asks for the password, generates the hardware config, checks that the configuration evaluates **before** touching the disk, asks you to type `YES`, partitions with disko (LUKS passphrase prompt), installs, and copies the repo to `~/nix-conf`.

After rebooting, log in and run `startx`.

> LUKS is controlled by `useLuks` in `hosts/t420/disko.nix` (on by default). Only fresh installs with `install.sh` are encrypted; Option A keeps whatever the existing system has.

## Daily use

```sh
cd ~/nix-conf
sudo nixos-rebuild switch --flake .#t420   # apply changes
nix flake update                           # update inputs (then rebuild)
git add -A && git commit && git push
```

Nix flakes only see files tracked by git, so run `git add` on new files before rebuilding.

## Customizing

- **Colors and fonts:** edit `home/theme.nix`. i3, polybar, alacritty, rofi, dunst, yazi, zathura and tmux all follow it.
- **Programs:** add packages in `home/apps.nix` (terminal tools) or `home/default.nix`.
- **System (generic):** `modules/common.nix` and `modules/desktop.nix`.
- **Per machine:** `hosts/<name>/default.nix` (hostname, boot loader, GPU).
- **User:** set `user` in `flake.nix`.
- **Neovim:** plugins and language servers in `home/nvim.nix`, behavior in `home/nvim.lua`. LSP servers and formatters come from Nix, so there is no Mason.
- **Shortcuts:** keep `home/shortcuts.txt` in sync when you change keybindings.

## Neovim quick reference

Leader key is `Space`.

| Keys | Action |
| --- | --- |
| `<leader>e` / `<leader>fe` | File tree sidebar (neo-tree) / focus it |
| `-` | Oil (edit the current folder) |
| `<leader>ff` / `fg` / `fb` | Find files / search text / buffers |
| `<leader>gg` / `gn` | lazygit / neogit (git panel) |
| `<C-\>` or `<leader>tt` | Terminal inside Neovim (toggleterm) |
| `<leader>th` / `tv` | Terminal bottom / right |
| `<F5>` | Start/continue debugging |
| `<F10>` `<F11>` `<F12>` | Step over / into / out |
| `<leader>db` / `du` / `dr` | Breakpoint / DAP UI / DAP REPL |
| `gd` / `gr` / `gi` / `K` | Definition / references / implementations / hover |
| `<leader>rn` / `ca` | Rename / code actions |
| `<leader>cf` | Format file (also automatic on save) |
| `<leader>xx` / `xd` / `xs` | Project / file / symbols (trouble) |
| `<leader>on` / `of` / `od` | New note / find note / today's note |

Languages with LSP: Python, JS/TS, Java, SQL, Go, C/C++, Rust, Nix, Lua, Bash, HTML/CSS/JSON, YAML, Markdown.
Debuggers: Python (debugpy) and Go (dlv).

## Another machine

Shared config lives in `modules/`; only machine-specific bits live in `hosts/<name>/`.

1. `mkdir -p hosts/<name> && cp hosts/t420/disko.nix hosts/<name>/`
2. `nixos-generate-config --show-hardware-config > hosts/<name>/hardware-configuration.nix`
3. Create `hosts/<name>/default.nix` (hostname, boot loader, GPU). Reuse an
   `inputs.nixos-hardware.nixosModules.<your-model>` module when available.
4. Add to `flake.nix`:
   ```nix
   nixosConfigurations.<name> = mkHost "<name>" [ ];
   ```
   For a fresh install, also add a `.<name>-install` output with disko.

> **BIOS (no UEFI):** systemd-boot needs UEFI. For BIOS use GRUB and add a
> `{ size = "1M"; type = "EF02"; }` partition to that host's `disko.nix`.

## OpenCode (V2)

`nixpkgs` only ships OpenCode 1.x. V2 lives in the `dev` branch of
`anomalyco/opencode`, which publishes a flake. `modules/opencode.nix` is
included but **disabled by default** (it builds from source). Enable it by
uncommenting the line in `flake.nix`:

```nix
# ./modules/opencode.nix
```

Then `nix flake lock && sudo nixos-rebuild switch --flake .#t420`. To try it
without touching the system: `nix run github:anomalyco/opencode/dev`.

## Secrets

No passwords or keys are stored in this repo. User and root passwords are read from a hash in `/etc/secrets/password-hash`, created with `openssl passwd -6`.

## Troubleshooting

- **Home-manager fails on an existing file** (e.g. Firefox `profiles.ini`): the flake already sets `backupFileExtension = "backup"`, so the old file is renamed.
- **A package name does not exist:** names change between nixpkgs branches. Search with `nix search nixpkgs <name>`.
- **Conform does not format a language:** make sure its formatter (black, prettier, stylua...) is in `extraPackages` in `home/nvim.nix`.
- **Trouble:** this config uses Trouble v3 (`:Trouble diagnostics toggle`). The old v2 `:TroubleToggle` commands do not exist.
- **Backlight module empty in polybar:** check your device with `ls /sys/class/backlight/`. The T420 uses `acpi_video0`.
- **A polybar click does nothing:** scripts run with a minimal PATH, so use absolute paths (`${pkgs.foo}/bin/foo`).

## TODO

Not implemented yet; planned for when I have another laptop:

- [x] Try not to use the translator so much.
- [x] One folder per machine under `hosts/<name>/`
- [x] `install.sh` with disk selection
- [ ] "Lite" profile for low-RAM machines
- [x] Add screenshots to the README
