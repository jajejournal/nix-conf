{ config, pkgs, lib, ... }:
let
  t = import ./theme.nix;
  mod = "Mod4";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  bl = "${pkgs.brightnessctl}/bin/brightnessctl";
  powermenu = ''rofi -show power -modi "power:${pkgs.rofi-power-menu}/bin/rofi-power-menu"'';
  shot = "${pkgs.maim}/bin/maim";
  clip = "${pkgs.xclip}/bin/xclip -selection clipboard -t image/png";
in
{
  xsession = {
    enable = true;
    initExtra = ''
      ${pkgs.xsetroot}/bin/xsetroot -solid "${t.bg}"
      ${pkgs.xset}/bin/xset r rate 250 40
    '';
    windowManager.i3 = {
      enable = true;
      config = {
        modifier = mod;
        terminal = "alacritty";
        menu = "rofi -show drun";
        bars = [ ]; # la barra es polybar
        fonts = { names = [ t.font.mono ]; size = 10.0; };
        gaps = { inner = 8; smartGaps = true; };
        window = {
          border = 2; titlebar = false; hideEdgeBorders = "smart";
          # Ventanas que se abren flotantes (pequeñas y centradas)
          commands = [
            { command = "floating enable, resize set 760 460, move position center"; criteria = { class = "^popup$"; }; }
            { command = "floating enable, resize set 860 520, move position center"; criteria = { class = "(?i)pavucontrol"; }; }
            { command = "floating enable, resize set 700 450, move position center"; criteria = { class = "(?i)blueman"; }; }
            { command = "floating enable, move position center"; criteria = { class = "^Yad$"; }; }
            { command = "floating enable"; criteria = { window_role = "^(pop-up|dialog|task_dialog|About)$"; }; }
            { command = "floating enable, sticky enable"; criteria = { title = "^Picture-in-Picture$"; }; }
          ];
        };
        floating = { border = 2; titlebar = false; };
        focus.followMouse = false;

        colors = {
          background = t.bg;
          focused         = { border = t.blue;    background = t.bg; text = t.fg;  indicator = t.cyan; childBorder = t.blue; };
          focusedInactive = { border = t.surface; background = t.bg; text = t.dim; indicator = t.surface; childBorder = t.surface; };
          unfocused       = { border = t.surface; background = t.bg; text = t.dim; indicator = t.surface; childBorder = t.surface; };
          urgent          = { border = t.red;     background = t.bg; text = t.fg;  indicator = t.red; childBorder = t.red; };
          placeholder     = { border = t.surface; background = t.bg; text = t.dim; indicator = t.surface; childBorder = t.surface; };
        };

        startup = [
          { command = "systemctl --user restart polybar"; always = true; notification = false; }
        ];

        keybindings = lib.mkOptionDefault {
          # Apps
          "${mod}+b" = "exec firefox";
          "${mod}+e" = "exec alacritty -e yazi";
          "${mod}+Shift+b" = "exec alacritty -e btop";
          "${mod}+m" = "exec alacritty -e cmus";
          "${mod}+Shift+Return" = "exec alacritty --class popup,popup";  # terminal flotante
          "${mod}+Escape" = "exec ${pkgs.i3lock}/bin/i3lock -c 000000";
          "${mod}+Shift+e" = "exec ${powermenu}";

          # Foco y movimiento estilo vim (h j k l)
          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";
          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+l" = "move right";
          "${mod}+backslash" = "split h";
          "${mod}+minus" = "split v";

          # Capturas de pantalla (Print = al portapapeles, Shift+Print = guarda en ~/Pictures)
          "Print" = "exec --no-startup-id ${shot} -s | ${clip}";
          "Shift+Print" = "exec --no-startup-id ${shot} -s ~/Pictures/$(date +%F_%H-%M-%S).png";

          # Teclas físicas del ThinkPad
          "XF86AudioRaiseVolume" = "exec --no-startup-id ${wpctl} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec --no-startup-id ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute"        = "exec --no-startup-id ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute"     = "exec --no-startup-id ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          "XF86MonBrightnessUp"  = "exec --no-startup-id ${bl} set 5%+";
          "XF86MonBrightnessDown"= "exec --no-startup-id ${bl} set 5%-";
          # Botón ThinkVantage -> menú de apagado/reinicio/bloqueo
          "XF86Launch1" = "exec ${powermenu}";
        };
      };
    };
  };
}
