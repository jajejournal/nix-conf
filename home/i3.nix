{ config, pkgs, lib, ... }:
let
  t = import ./theme.nix;
  mod = "Mod4";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  bl = "${pkgs.brightnessctl}/bin/brightnessctl";
  powermenu = ''rofi -show power -modi "power:${pkgs.rofi-power-menu}/bin/rofi-power-menu"'';
  shot = "${pkgs.maim}/bin/maim";
  clip = "${pkgs.xclip}/bin/xclip -selection clipboard -t image/png";

  # Terminal apps that have their own class so i3 sends them to their workspace
  term = "${pkgs.alacritty}/bin/alacritty";
  home = config.home.homeDirectory;
  apps = {
    code  = { name = "Neovim (code)";  cmd = "${term} --class code -e nvim";            ws = "3"; };
    files = { name = "Files (yazi)";  cmd = "${term} --class files -e yazi";           ws = "4"; };
    notes = { name = "Notes (neovim)";   cmd = "${term} --class notes -e nvim ${home}/Notes"; ws = "5"; };
    music = { name = "Music (cmus)";    cmd = "${term} --class music -e cmus";           ws = "6"; };
  };
  toWs = ws: "move container to workspace number ${ws}, workspace number ${ws}";
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
        bars = [ ]; # the bar is polybar
        fonts = { names = [ t.font.mono ]; size = 10.0; };
        gaps = { inner = 8; smartGaps = true; };
        window = {
          border = 2; titlebar = false; hideEdgeBorders = "none";
          # Windows that open floating (small & centered)
          commands = [
            { command = "floating enable, resize set 760 460, move position center"; criteria = { class = "^popup$"; }; }
            { command = "floating enable, resize set 960 620, move position center"; criteria = { class = "^cheatsheet$"; }; }
            { command = "floating enable, resize set 860 520, move position center"; criteria = { class = "(?i)pavucontrol"; }; }
            { command = "floating enable, resize set 700 450, move position center"; criteria = { class = "(?i)blueman"; }; }
            { command = "floating enable, move position center"; criteria = { class = "^Yad$"; }; }
            { command = "floating enable"; criteria = { window_role = "^(pop-up|dialog|task_dialog|About)$"; }; }
            { command = "floating enable, sticky enable"; criteria = { title = "^Picture-in-Picture$"; }; }
            { command = "floating enable, move position center"; criteria = { class = "^mpv$"; }; }
            # Each program opens in its workspace (bar icons)
            { command = toWs "2"; criteria = { class = "(?i)^firefox$"; }; }
            { command = toWs apps.code.ws;  criteria = { class = "^code$"; }; }
            { command = toWs apps.files.ws; criteria = { class = "^files$"; }; }
            { command = toWs apps.notes.ws; criteria = { class = "^notes$"; }; }
            { command = toWs apps.music.ws; criteria = { class = "^music$"; }; }
          ];
        };
        floating = { border = 2; titlebar = false; };
        focus.followMouse = false;

        colors = {
          background = t.bg;
          focused         = { border = t.accent; background = t.bg; text = t.fg;  indicator = t.accent; childBorder = t.accent; };
          focusedInactive = { border = t.dim;    background = t.bg; text = t.dim; indicator = t.dim;    childBorder = t.dim; };
          unfocused       = { border = t.dim;    background = t.bg; text = t.dim; indicator = t.dim;    childBorder = t.dim; };
          urgent          = { border = t.red;    background = t.bg; text = t.fg;  indicator = t.red;    childBorder = t.red; };
          placeholder     = { border = t.dim;    background = t.bg; text = t.dim; indicator = t.dim;    childBorder = t.dim; };
        };

        startup = [
          { command = "systemctl --user restart polybar"; always = true; notification = false; }
        ];

        keybindings = lib.mkOptionDefault {
          # Apps
          "${mod}+b" = "exec firefox";
          "${mod}+e" = "exec ${apps.files.cmd}";
          "${mod}+n" = "exec ${apps.notes.cmd}";
          "${mod}+Shift+b" = "exec alacritty -e btop";
          "${mod}+m" = "exec ${apps.music.cmd}";
          "${mod}+Shift+Return" = "exec alacritty --class popup";  # floating terminal
          "${mod}+ccedilla" = "exec alacritty --class cheatsheet -e less ${config.xdg.configHome}/shortcuts.txt";
          "${mod}+Escape" = "exec ${pkgs.i3lock}/bin/i3lock -c 000000";
          "${mod}+Shift+e" = "exec ${powermenu}";

          # Vim-like focus & movement (h j k l)
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

          # Screenshots (Print = to clipboard, Shift+Print = save to ~/Pictures)
          "Print" = "exec --no-startup-id ${shot} -s | ${clip}";
          "Shift+Print" = "exec --no-startup-id ${shot} -s ~/Pictures/$(date +%F_%H-%M-%S).png";

          # ThinkPad physical keys
          "XF86AudioRaiseVolume" = "exec --no-startup-id ${wpctl} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec --no-startup-id ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute"        = "exec --no-startup-id ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute"     = "exec --no-startup-id ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          "XF86MonBrightnessUp"  = "exec --no-startup-id ${bl} set 5%+";
          "XF86MonBrightnessDown"= "exec --no-startup-id ${bl} set 5%-";
          # ThinkVantage button -> power/reboot/lock menu
          "XF86Launch1" = "exec ${powermenu}";
        };
      };
    };
  };

  # Rofi entries to open each program in its workspace
  xdg.desktopEntries =
    (lib.mapAttrs' (k: a: lib.nameValuePair "ws-${k}" { name = a.name; exec = a.cmd; terminal = false; }) apps)
    // {
      # hide original entries to avoid duplicates in rofi
      yazi = { name = "Yazi"; exec = "yazi"; noDisplay = true; };
      cmus = { name = "cmus"; exec = "cmus"; noDisplay = true; };
      nvim = { name = "Neovim"; exec = "nvim"; noDisplay = true; };
    };
}
