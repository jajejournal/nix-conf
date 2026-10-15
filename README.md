# nix-conf — Mi configuración NixOS / dotfiles

Este repositorio contiene mi configuración (flake) y dotfiles para un portátil de trabajo. Está pensada para ser práctica, reproducible y segura —incluye el sistema NixOS, la configuración de i3/polybar/alacritty, y la configuración de Neovim como IDE ligero.

He aquí una guía clara y portable para instalar y adaptar esta configuración en otras máquinas, junto con ideas para mejorar la instalación y la compatibilidad entre distintos equipos y arquitecturas.

---

## Resumen rápido

- Sistema: NixOS (flake)
- Window manager: i3 (o i3-compatible)
- Terminal: alacritty / st (según la máquina)
- Editor: Neovim con LSP, completado, formateo al guardar (conform) y panel de diagnósticos (trouble)
- Gestión de dotfiles: flake + scripts de instalación
- Seguridad: las contraseñas no están en el repo; se usan secretos (hash en `/etc/secrets`)

---

## TODOS

- [ ] Quitar o remapear atajo conflictivo en Neovim (`<leader>f`)
- [ ] Evitar que Prettier formatee los archivos de notas del vault
- [ ] Añadir `.gitignore` para backups y artefactos (`*.bak.*`, `result`)
- [ ] Documentar el flujo de LUKS y la variable `PONER_SERIAL` para soportar otras máquinas
- [ ] Revisar y simplificar mappings de Trouble si todos los hosts usan v3
- [ ] Actualizar `shortcuts.txt` con los atajos reales
- [ ] Añadir plantillas `machines/<serial>.nix` para nuevos equipos
- [ ] Añadir tests básicos / comprobaciones headless para Neovim (conform, trouble)
- [ ] Mejorar `install.sh` con flags `--disk`, `--luks`, `--arch`, `--user`, `--dry-run`

---

## Estructura (esquema de carpetas)

Raíz del repo (esquema orientativo — usa este apartado como mapa para añadir overrides por máquina):

```
nix-conf/
├── flake.nix
├── install.sh
├── disko.nix
├── README.md
├── .gitignore
├── machines/
│   ├── serial-<SERIAL>.nix
│   └── README.md
├── home/
│   ├── nvim.nix
│   ├── nvim.lua
│   └── ... (otras configuraciones de home-manager)
├── scripts/
│   ├── bin/
│   │   └── select-disk        # script interactivo recomendado
│   └── helpers/
├── screenshots/
│   ├── desktop-overview.png
│   ├── polybar.png
│   ├── alacritty-nvim.png
│   ├── neovim-completion.png
│   ├── alpha-start.png
│   ├── install-dryrun.png
│   └── disko-layout.png
├── secrets/                   # IGNORAR: .gitignored — instrucciones para cifrar y desplegar
└── docs/
    ├── machines/README.md
    └── contributing.md
```

---

## Soportado (por diseño)

- Arquitectura principal: x86_64 (amd64)
- Soporte adicional: ARM64 (aarch64) — requiere ajustar variables de flake y paquetería
- UEFI y BIOS (legacy) — el instalador detecta UEFI si existe `/sys/firmware/efi`
- Opcional: LUKS (encriptado de disco) — el flake y los módulos de `disko` están preparados, pero la instalación por defecto no fuerza cifrado

---

## Objetivos de compatibilidad (qué incluir en el instalador)

Para que la instalación sea reutilizable en varias laptops y arquitecturas, el instalador debe:

- Detectar la arquitectura (x86_64 / aarch64) y ajustar la flake/paquetes.
- Detectar si el sistema arranca en UEFI o BIOS y adaptar la partición EFI.
- Ofrecer selección interactiva del disco destino (o permitir pasar `--disk /dev/sdX`).
- Soportar LUKS como opción (`--luks`) y permitir elegir passphrase o leer desde stdin.
- Validar la flake y los cambios con `nix eval` / `nix build` antes de tocar particiones.
- Crear usuario con UID/GID configurable y copiar las claves públicas SSH.
- Confirmar explícitamente (y mostrar un resumen) antes de aplicar `disko`/particionado.
- Registrar un `serial` o `HOST_ID` por máquina para personalizaciones (no hardcodear).

---

## Instalación (rápida)

Advertencia: la instalación toca particiones. Haz backup.

1. Clona el repo:
   git clone https://github.com/jajejournal/nix-conf.git
   cd nix-conf

2. Revisa `install.sh` y adapta las variables si vas a usar otra arquitectura o esquema de disco.

3. Ejecuta (modo seguro — solo `nix eval` primero):
   ./install.sh --dry-run
   Si todo se ve bien:
   sudo ./install.sh

4. Después del reboot, aplica la configuración del usuario:
   sudo nixos-rebuild switch --flake .#t420

---

## Diseño del particionado (disko)

El repositorio incluye un módulo `disko.nix` que define layouts. Recomendaciones:

- Mantén plantillas para:
  - UEFI + LUKS + LVM (portátil cifrado)
  - UEFI simple (no cifrado)
  - BIOS legacy (MBR)
- No infieras el disco por defecto: lista discos y pide confirmación interactiva.
- Antes de aplicar `disko`, ejecuta `nix eval --impure` o `nixos-generate-config` para validar.
- Guarda la configuración de particiones por tipo de hardware (`machines/<serial>.nix`) y documenta cómo añadir un nuevo perfil.

Sugerencia de flujo seguro:
- detectar discos: `lsblk -o NAME,MODEL,SIZE,TYPE,MOUNTPOINT`
- pedir selección interactiva (fzf/whiptail)
- mostrar diff de cambios que `disko` hará
- confirmar YES/NO

---

## Usuario y secretos

- No subas contraseñas ni claves privadas.
- Guarda secretos en `/etc/secrets` (o usa `age`, `gpg` o un secret manager).
- El instalador debe:
  - crear el usuario (nombre, UID opcional, grupos)
  - añadir claves públicas SSH desde `~/.ssh/authorized_keys` (o preguntarlas)
  - permitir inyección de `secrets` (hash o fichero en el host) durante la instalación

Organización recomendada:
- `machines/serial-<SERIAL>.nix` — overrides por hardware (discos, drivers)
- `users/<username>.nix` — configuración específica del usuario (dotfiles, paquetes)
- `secrets/` — .gitignored, con instrucciones para cifrar y desplegar

---

## Pruebas rápidas y comprobaciones

- Comprobar que conform y trouble cargan:
  nvim --headless -c 'lua print("conform:", pcall(require,"conform"))' -c 'qa'
  nvim --headless -c 'lua print("trouble:", pcall(require,"trouble"))' -c 'qa'

- Test de formateo:
  printf "%s\n" "def foo():" "    print(  \"hello\" )" > /tmp/test_format.py
  nvim --headless /tmp/test_format.py -c 'w' -c 'qa'
  sed -n '1,120p' /tmp/test_format.py

---

## Sugerencias para hacer `install.sh` más portable (ideas prácticas)

- Añadir banderas:
  --disk /dev/sdX         dispositivo objetivo
  --arch x86_64|aarch64   forzar arquitectura
  --luks                  habilitar cifrado
  --user NAME             nombre de usuario a crear
  --dry-run               validar sin aplicar
- Validaciones:
  - Comprobar UEFI: `[ -d /sys/firmware/efi ]`
  - Validar flake: `nix build .#nixosConfigurations.t420.config.system.build.toplevel`
  - Mostrar `lsblk` y pedir confirmación
- Registro y logging del instalador (guardarlo en `/var/log/install-YYYYMMDD.log`)

---

## Screenshots recomendados (qué tomar y por qué)

Incluye capturas optimizadas para mostrar las partes más vistosas y útiles de la configuración. Nombres de archivo sugeridos:

- screenshots/desktop-overview.png  
  Captura completa del escritorio (i3) mostrando barra, ventanas y tema (Material Ocean).

- screenshots/polybar.png  
  Zoom en polybar mostrando battery, wifi, workspace, reloj y scripts de estado.

- screenshots/alacritty-nvim.png  
  Terminal con Neovim abierto mostrando un archivo con LSP activo y panel de trouble abierto.

- screenshots/neovim-completion.png  
  Neovim mostrando autocompletado y snippets (popup de cmp).

- screenshots/alpha-start.png  
  Pantalla de inicio (`alpha`) con botones custom.

- screenshots/install-dryrun.png  
  Salida del instalador en modo `--dry-run` (nix eval / disco propuesto). Útil para documentación de seguridad.

- screenshots/disko-layout.png  
  Diagrama o screenshot mostrando el layout de particiones (p.ej. `lsblk` o `parted -l`).

Consejos para capturas:
- Usa fondo oscuro y tamaño 16:9 para consistencia.
- Añade un pie de foto breve en el README (ejemplo: `desktop-overview.png — i3 + Material Ocean theme`).
- Si subes imágenes a Imgur o al repo, referencia su URL en el README.

---

## Troubleshooting (problemas frecuentes)

- `nixos-rebuild` falla por paquetes inexistentes:
  - Revisa `home/nvim.nix` y `extraPackages` (algunos nombres cambian entre ramas de nixpkgs).
- `conform` no formatea:
  - Asegúrate de que el binario (black, prettier, stylua, etc.) esté en `extraPackages`.
- `Trouble` comandos:
  - v3 usa `:Trouble diagnostics toggle`; v2 usa `:TroubleToggle workspace_diagnostics`. El config incluye mapeo robusto para ambas.

---

## Contribuir

- Haz fork y PR con cambios pequeños y pruebas.
- Para añadir soporte a una nueva laptop:
  - Añade `machines/<serial-or-model>.nix` con overrides.
  - Documenta los pasos en `machines/README.md`.
