# Programas de uso diario, casi todos para terminal o muy ligeros
{ config, pkgs, lib, ... }:
let t = import ./theme.nix; in
{
  home.packages = with pkgs; [
    # Documentos y texto
    pandoc glow poppler-utils            # glow = markdown en terminal; pdftotext/pdftoppm
    # Imágenes
    imv chafa                            # imv = visor ligero; chafa = ver imágenes en la terminal
    # Audio / video
    cmus yt-dlp ffmpeg
    # Archivos
    p7zip unzip zip ncdu duf
    # Red / bluetooth en terminal
    bluetui
    # Sistema
    ripgrep fd jq tealdeer xdg-utils
    # CD / DVD
    abcde cdrkit libdvdcss
  ];

  # PDF y ebooks: zathura (negro; Ctrl+r invierte colores del PDF)
  programs.zathura = {
    enable = true;
    options = {
      default-bg = t.bg;
      default-fg = t.fg;
      statusbar-bg = t.bgAlt;
      statusbar-fg = t.fg;
      inputbar-bg = t.bgAlt;
      inputbar-fg = t.fg;
      highlight-color = t.yellow;
      highlight-active-color = t.blue;
      recolor = true;
      recolor-lightcolor = t.bg;
      recolor-darkcolor = t.fg;
      selection-clipboard = "clipboard";
      font = "${t.font.mono} 10";
    };
  };

  # Video: mpv ajustado a la HD 3000 (también funciona en terminal con --vo=tct)
  programs.mpv = {
    enable = true;
    config = {
      profile = "fast";
      hwdec = "auto-safe";
      keep-open = true;
      save-position-on-quit = true;
      background-color = t.bg;
    };
  };

  xdg.configFile."imv/config".text = ''
    [options]
    background = 000000
  '';

  # Terminal: tmux, lazygit
  programs.tmux = {
    enable = true;
    mouse = true;
    baseIndex = 1;
    keyMode = "vi";
    escapeTime = 0;
    terminal = "tmux-256color";
    prefix = "C-a";
    extraConfig = ''
      set -g status-position top
      set -g status-style "bg=${t.bg},fg=${t.fg}"
      set -g window-status-current-style "fg=${t.blue},bold"
      set -g pane-active-border-style "fg=${t.blue}"
      set -g pane-border-style "fg=${t.surface}"
    '';
  };
  programs.lazygit.enable = true;

  # Automontaje de USB y discos ópticos
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "never";
  };

  # Aplicaciones por defecto
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura.desktop";
      "application/epub+zip" = "org.pwmt.zathura.desktop";
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "audio/mpeg" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };
  };
}
