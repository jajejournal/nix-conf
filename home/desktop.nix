{ config, pkgs, lib, ... }:
let t = import ./theme.nix; in
{
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
    fade = true;
    fadeDelta = 4;
    shadow = false;
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        font = "${t.font.mono} 10";
        frame_width = 2;
        frame_color = t.blue;
        background = t.bg;
        foreground = t.fg;
        offset = "12x12";
        origin = "top-right";
        corner_radius = 0;
      };
      urgency_low = { background = t.bg; foreground = t.dim; };
      urgency_normal = { background = t.bg; foreground = t.fg; frame_color = t.blue; };
      urgency_critical = { background = t.bg; foreground = t.fg; frame_color = t.red; };
    };
  };

  programs.rofi = {
    enable = true;
    font = "${t.font.mono} 11";
    theme = "ocean";
    extraConfig = { show-icons = false; display-drun = "  "; };
  };
  xdg.dataFile."rofi/themes/ocean.rasi".text = ''
    * {
      bg: ${t.bg}; bgalt: ${t.bgAlt}; fg: ${t.fg}; dim: ${t.dim}; accent: ${t.blue};
      background-color: transparent; text-color: @fg;
    }
    window { background-color: @bg; border: 2px; border-color: @accent; width: 40%; padding: 12px; }
    mainbox { children: [inputbar, listview]; spacing: 10px; }
    inputbar { children: [prompt, entry]; spacing: 8px; padding: 8px; background-color: @bgalt; }
    prompt { text-color: @accent; }
    entry { placeholder: "buscar..."; placeholder-color: @dim; }
    listview { lines: 8; spacing: 4px; }
    element { padding: 6px; }
    element selected.normal { background-color: @accent; text-color: @bg; }
    element-text { background-color: transparent; text-color: inherit; }
  '';

  # GTK / cursor / iconos
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
  gtk = {
    enable = true;
    theme = { name = "Adwaita-dark"; package = pkgs.gnome-themes-extra; };
    iconTheme = { name = "Papirus-Dark"; package = pkgs.papirus-icon-theme; };
    font = { name = t.font.ui; size = 10; };
    gtk3.extraCss = "window, .background { background-color: ${t.bg}; }";
  };

  # Firefox declarativo
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "browser.startup.homepage" = "about:blank";
        "browser.aboutConfig.showWarning" = false;
        "ui.systemUsesDarkTheme" = 1;
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "media.ffmpeg.vaapi.enabled" = true;
      };
      userContent = ''
        @-moz-document url-prefix("about:") { :root { --in-content-page-background: ${t.bg} !important; } }
      '';
    };
  };
}
