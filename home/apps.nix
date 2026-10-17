# Programs for terminal/lightweight
{
  config,
  pkgs,
  lib,
  ...
}:
let
  t = import ./theme.nix;
in
{
  home.packages = with pkgs; [
    # Documents and text
    pandoc
    glow
    poppler-utils # glow = markdown in terminal; pdftotext/pdftoppm
    # Images
    imv
    chafa
    ueberzugpp
    feh # imv = lightweight image viewer; chafa = terminal image viewer
    # Audio / video
    cmus
    yt-dlp
    ffmpeg
    # Files
    p7zip
    unzip
    zip
    ncdu
    duf
    # Network / bluetooth (terminal)
    bluetui
    # System
    ripgrep
    fd
    jq
    tealdeer
    xdg-utils
    # CD / DVD
    abcde
    cdrkit
    libdvdcss
    # Everyday GUI apps
    libreoffice-fresh # office documents
    keepassxc # password manager
    qalculate-gtk # calculator
    flameshot # screenshots with drawing
    obs-studio # screen recording
    obsidian # notes / second brain
    tesseract # OCR (text from images)
    arandr # configure external monitors
    gparted # partition disks (GUI)
    unclutter # hide the mouse cursor while typing
    syncthing # sync folders between machines
  ];

  # PDF and ebooks: zathura (black; Ctrl+r invert PDF colors)
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

  # Video: mpv tuned for the HD 3000 (also works in the terminal with --vo=tct)
  programs.mpv = {
    enable = true;
    config = {
      profile = "fast";
      hwdec = "auto-safe";
      keep-open = true;
      save-position-on-quit = true;
      background-color = t.bg;
      autofit-larger = "760x460"; # same size as the floating terminal
      image-display-duration = "inf";
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

  # USB and optical disc automounting
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "never";
  };

  # Default apps
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
      # Images open in mpv on purpose: it sizes the window to the image,
      # so they show with no borders and no extra chrome.
      "image/png" = "mpv.desktop";
      "image/jpeg" = "mpv.desktop";
      "image/gif" = "mpv.desktop";
      "image/webp" = "mpv.desktop";
      # Office documents
      "application/msword" = "libreoffice-writer.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "libreoffice-writer.desktop";
      "application/vnd.oasis.opendocument.text" = "libreoffice-writer.desktop";
      "application/vnd.ms-excel" = "libreoffice-calc.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "libreoffice-calc.desktop";
      "application/vnd.oasis.opendocument.spreadsheet" = "libreoffice-calc.desktop";
      "application/vnd.ms-powerpoint" = "libreoffice-impress.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "libreoffice-impress.desktop";
      "application/vnd.oasis.opendocument.presentation" = "libreoffice-impress.desktop";
      # Folders and archives
      "inode/directory" = "thunar.desktop";
      "application/zip" = "org.gnome.FileRoller.desktop";
      "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
      "application/x-tar" = "org.gnome.FileRoller.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };
  };
}
