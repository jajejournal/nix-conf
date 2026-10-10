{ config, pkgs, lib, ... }:
let
  t = import ./theme.nix;
  i = t.icon;
  col = c: s: "%{F${c}}${s}%{F-}";
  act = cmd: body: "%{A1:${cmd}:}${body}%{A}";   # clic izquierdo ejecuta cmd
  term = "${pkgs.alacritty}/bin/alacritty";
  # Ventana pequeña flotante: alacritty con clase "popup" (i3 la flota, ver i3.nix)
  popup = prog: "${term} --class popup,popup -e ${prog}";
  btop = popup "${pkgs.btop}/bin/btop";
  nmCmd = popup "/run/current-system/sw/bin/nmtui";
  calendar = "${pkgs.yad}/bin/yad --calendar --title=Calendario --no-buttons --close-on-unfocus";

  batteryInfo = pkgs.writeShellScript "battery-info" ''
    export PATH=${lib.makeBinPath [ pkgs.coreutils ]}
    b=/sys/class/power_supply/BAT0
    r() { cat "$b/$1" 2>/dev/null; }
    echo
    echo "   Batería"
    echo "   ───────────────────────"
    echo "   Estado:   $(r status)"
    echo "   Carga:    $(r capacity)%"
    full=$(r energy_full); design=$(r energy_full_design)
    if [ -z "$full" ]; then full=$(r charge_full); design=$(r charge_full_design); fi
    if [ -n "$full" ] && [ -n "$design" ] && [ "$design" -gt 0 ]; then
      echo "   Salud:    $((full * 100 / design))%"
    fi
    c=$(r cycle_count)
    if [ -n "$c" ]; then echo "   Ciclos:   $c"; fi
    pw=$(r power_now)
    if [ -n "$pw" ]; then echo "   Consumo:  $((pw / 1000)) mW"; fi
    echo
    read -rsn1 -p "   Presiona una tecla para cerrar"
  '';
  battCmd = popup "${batteryInfo}";

  btStatus = pkgs.writeShellScript "polybar-bt" ''
    export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.bluez ]}
    out=$(bluetoothctl show 2>/dev/null)
    case "$out" in
      *"Powered: yes"*)
        n=$(bluetoothctl devices Connected 2>/dev/null | wc -l)
        if [ "$n" -gt 0 ]; then
          echo "${col t.blue "${i "f294"} $n"}"
        else
          echo "${col t.cyan (i "f294")}"
        fi
        ;;
      *)
        echo "${col t.dim "${i "f294"} off"}"
        ;;
    esac
  '';
  btToggle = pkgs.writeShellScript "bt-toggle" ''
    export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.bluez pkgs.util-linux ]}
    out=$(bluetoothctl show 2>/dev/null)
    case "$out" in
      *"Powered: yes"*) bluetoothctl power off ;;
      *) rfkill unblock bluetooth; bluetoothctl power on ;;
    esac
  '';
in
{
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override { i3Support = true; pulseSupport = true; };
    script = "polybar main &";
    settings = {
      "bar/main" = {
        width = "100%";
        height = 28;
        fixed-center = true;
        background = t.bg;
        foreground = t.fg;
        line-size = 2;
        padding-left = 1;
        padding-right = 1;
        module-margin = 1;
        font-0 = "${t.font.mono}:size=10;3";
        font-1 = "${t.font.mono}:size=12;4";
        modules-left = "i3";
        modules-center = "date";
        modules-right = "cpu memory pulseaudio backlight bluetooth battery network eth xkeyboard";
        cursor-click = "pointer";
      };

      "module/i3" = {
        type = "internal/i3";
        pin-workspaces = true;
        show-urgent = true;
        strip-wsnumbers = true;
        index-sort = true;
        wrapping-scroll = false;
        ws-icon-0 = "1;${i "f120"}";
        ws-icon-1 = "2;${i "f269"}";
        ws-icon-2 = "3;${i "f121"}";
        ws-icon-3 = "4;${i "f07b"}";
        ws-icon-4 = "5;${i "f02d"}";
        ws-icon-5 = "6;${i "f001"}";
        ws-icon-default = i "f111";
        label-focused = "%icon%";
        label-focused-foreground = t.blue;
        label-focused-underline = t.blue;
        label-focused-padding = 1;
        label-unfocused = "%icon%";
        label-unfocused-foreground = t.dim;
        label-unfocused-padding = 1;
        label-visible = "%icon%";
        label-visible-padding = 1;
        label-urgent = "%icon%";
        label-urgent-foreground = t.red;
        label-urgent-padding = 1;
      };

      # Clic: calendario
      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = "%a %d %b";
        time = "%H:%M";
        label = act calendar "${col t.cyan (i "f073")} %date%   ${col t.cyan (i "f017")} %time%";
      };

      # Clic: btop
      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        label = act btop "${col t.cyan (i "f2db")} %percentage:2%%";
      };
      "module/memory" = {
        type = "internal/memory";
        interval = 3;
        label = act btop "${col t.purple (i "f0a0")} %percentage_used%%";
      };

      # Clic: mezclador de audio (pavucontrol)
      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        format-volume = "<label-volume>";
        label-volume = act "${pkgs.pavucontrol}/bin/pavucontrol" "${col t.green (i "f028")} %percentage%%";
        label-muted = act "${pkgs.pavucontrol}/bin/pavucontrol" "${col t.dim (i "f026")} mute";
      };

      "module/backlight" = {
        type = "internal/backlight";
        card = "acpi_video0";
        format = "<label>";
        label = "${col t.yellow (i "f185")} %percentage%%";
      };

      # Clic izquierdo: administrador bluetooth · clic derecho: encender/apagar
      "module/bluetooth" = {
        type = "custom/script";
        exec = "${btStatus}";
        interval = 5;
        click-left = "${pkgs.blueman}/bin/blueman-manager";
        click-right = "${btToggle}";
      };

      # Clic: detalles de batería (tlp-stat)
      "module/battery" = {
        type = "internal/battery";
        battery = "BAT0";
        adapter = "AC";
        full-at = 98;
        format-charging = "<label-charging>";
        format-discharging = "<ramp-capacity> <label-discharging>";
        format-full = "<label-full>";
        label-charging = act battCmd "${col t.green (i "f0e7")} %percentage%%";
        label-discharging = act battCmd "%percentage%%";
        label-full = "${col t.green (i "f240")} %percentage%%";
        ramp-capacity-0 = i "f244";
        ramp-capacity-1 = i "f243";
        ramp-capacity-2 = i "f242";
        ramp-capacity-3 = i "f241";
        ramp-capacity-4 = i "f240";
        ramp-capacity-foreground = t.orange;
      };

      # Clic: nmtui (elegir wifi)
      "module/network" = {
        type = "internal/network";
        interface-type = "wireless";
        interval = 3;
        format-connected = "<label-connected>";
        label-connected = act nmCmd "${col t.blue (i "f1eb")} %essid%";
        format-disconnected = "<label-disconnected>";
        label-disconnected = act nmCmd "${col t.dim (i "f1eb")} --";
      };

      "module/eth" = {
        type = "internal/network";
        interface-type = "wired";
        interval = 3;
        format-connected = "<label-connected>";
        label-connected = act nmCmd "${col t.blue (i "f0ac")} lan";
        format-disconnected = "";
      };

      "module/xkeyboard" = {
        type = "internal/xkeyboard";
        blacklist-0 = "num lock";
        blacklist-1 = "scroll lock";
        format = "<label-layout>";
        label-layout = "${col t.purple (i "f11c")} %layout%";
      };
    };
  };
}
