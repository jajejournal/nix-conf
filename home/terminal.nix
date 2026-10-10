{ config, pkgs, lib, ... }:
let t = import ./theme.nix; in
{
  programs.alacritty = {
    enable = true;
    settings = {
      font = { size = 11.0; normal.family = t.font.mono; };
      window = { padding = { x = 10; y = 8; }; opacity = 1.0; };
      colors = {
        primary = { background = t.bg; foreground = t.fg; };
        cursor = { text = t.bg; cursor = t.blue; };
        selection = { text = t.bg; background = t.blue; };
        normal = { black = "#000000"; red = t.red; green = t.green; yellow = t.yellow;
                   blue = t.blue; magenta = t.purple; cyan = t.cyan; white = "#eeffff"; };
        bright = { black = t.dim; red = t.red; green = t.green; yellow = t.yellow;
                   blue = t.blue; magenta = t.purple; cyan = t.cyan; white = "#ffffff"; };
      };
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = "set -g fish_greeting";
    shellAliases = { ll = "eza -l --icons"; la = "eza -la --icons"; cat = "bat"; v = "nvim"; };
  };
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = { success_symbol = "[❯](bold blue)"; error_symbol = "[❯](bold red)"; };
    };
  };
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    theme = {
      app.overall = { bg = t.bg; };
      mgr = {
        cwd = { fg = t.cyan; };
        border_style = { fg = t.surface; };
        find_keyword = { fg = t.yellow; bold = true; };
        marker_selected = { fg = t.bg; bg = t.green; };
        marker_copied = { fg = t.bg; bg = t.green; };
        marker_cut = { fg = t.bg; bg = t.red; };
        marker_marked = { fg = t.bg; bg = t.cyan; };
        count_selected = { fg = t.bg; bg = t.blue; };
        count_copied = { fg = t.bg; bg = t.green; };
        count_cut = { fg = t.bg; bg = t.red; };
      };
      indicator = {
        current = { fg = t.bg; bg = t.blue; bold = true; };
        parent = { fg = t.bg; bg = t.dim; };
        preview = { fg = t.bg; bg = t.surface; };
      };
      tabs = {
        active = { fg = t.bg; bg = t.blue; bold = true; };
        inactive = { fg = t.fg; bg = t.surface; };
      };
      mode = {
        normal_main = { fg = t.bg; bg = t.blue; bold = true; };
        normal_alt = { fg = t.blue; bg = t.surface; };
        select_main = { fg = t.bg; bg = t.green; bold = true; };
        select_alt = { fg = t.green; bg = t.surface; };
        unset_main = { fg = t.bg; bg = t.red; bold = true; };
        unset_alt = { fg = t.red; bg = t.surface; };
      };
      status = {
        overall = { fg = t.fg; bg = t.bg; };
        progress_normal = { fg = t.blue; bg = t.surface; };
        progress_error = { fg = t.red; bg = t.surface; };
      };
      filetype.rules = [
        { mime = "inode/directory"; fg = t.blue; bold = true; }
        { mime = "image/*"; fg = t.purple; }
        { mime = "video/*"; fg = t.yellow; }
        { mime = "audio/*"; fg = t.cyan; }
        { mime = "*"; fg = t.fg; }
      ];
    };
  };
  programs.zoxide.enable = true;
  programs.fzf.enable = true;
  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.git = {
    enable = true;
    settings = {
      user = { name = "jajejournal"; email = "jajejournal@gmail.com"; };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
  programs.gh = { enable = true; gitCredentialHelper.enable = true; };
}
