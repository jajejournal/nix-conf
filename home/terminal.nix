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
    theme.flavor = { dark = "ocean"; light = "ocean"; };
  };

  # Yazi theme "ocean": same structure as official flavors, colors from theme.nix
  xdg.configFile."yazi/flavors/ocean.yazi/flavor.toml".text = ''
    [mgr]
    cwd = { fg = "${t.cyan}" }
    find_keyword  = { fg = "${t.yellow}", bold = true, italic = true, underline = true }
    find_position = { fg = "${t.purple}", bg = "reset", bold = true, italic = true }
    marker_copied   = { fg = "${t.green}",  bg = "${t.green}" }
    marker_cut      = { fg = "${t.red}",    bg = "${t.red}" }
    marker_marked   = { fg = "${t.cyan}",   bg = "${t.cyan}" }
    marker_selected = { fg = "${t.yellow}", bg = "${t.yellow}" }
    count_copied   = { fg = "${t.bg}", bg = "${t.green}" }
    count_cut      = { fg = "${t.bg}", bg = "${t.red}" }
    count_selected = { fg = "${t.bg}", bg = "${t.yellow}" }
    border_symbol = "│"
    border_style  = { fg = "${t.dim}" }

    [tabs]
    active   = { fg = "${t.bg}", bg = "${t.accent}", bold = true }
    inactive = { fg = "${t.accent}", bg = "${t.surface}" }

    [mode]
    normal_main = { fg = "${t.bg}", bg = "${t.accent}", bold = true }
    normal_alt  = { fg = "${t.accent}", bg = "${t.surface}" }
    select_main = { fg = "${t.bg}", bg = "${t.cyan}", bold = true }
    select_alt  = { fg = "${t.cyan}", bg = "${t.surface}" }
    unset_main  = { fg = "${t.bg}", bg = "${t.red}", bold = true }
    unset_alt   = { fg = "${t.red}", bg = "${t.surface}" }

    [status]
    perm_sep   = { fg = "${t.dim}" }
    perm_type  = { fg = "${t.accent}" }
    perm_read  = { fg = "${t.yellow}" }
    perm_write = { fg = "${t.red}" }
    perm_exec  = { fg = "${t.green}" }
    progress_label  = { fg = "#ffffff", bold = true }
    progress_normal = { fg = "${t.green}", bg = "${t.surface}" }
    progress_error  = { fg = "${t.yellow}", bg = "${t.red}" }

    [pick]
    border   = { fg = "${t.accent}" }
    active   = { fg = "${t.purple}", bold = true }
    inactive = {}

    [input]
    border   = { fg = "${t.accent}" }
    title    = {}
    value    = {}
    selected = { reversed = true }

    [cmp]
    border = { fg = "${t.accent}" }

    [tasks]
    border  = { fg = "${t.accent}" }
    title   = {}
    hovered = { fg = "${t.purple}", bold = true }

    [which]
    border          = { fg = "${t.accent}" }
    cand            = { fg = "${t.cyan}" }
    rest            = { fg = "${t.dim}" }
    desc            = { fg = "${t.purple}" }
    separator       = "  "
    separator_style = { fg = "${t.dim}" }

    [help]
    on      = { fg = "${t.cyan}" }
    run     = { fg = "${t.purple}" }
    hovered = { reversed = true, bold = true }
    footer  = { fg = "${t.surface}", bg = "${t.fg}" }

    [spot]
    border   = { fg = "${t.accent}" }
    title    = { fg = "${t.accent}" }
    tbl_col  = { fg = "${t.cyan}" }
    tbl_cell = { fg = "${t.purple}", bg = "${t.surface}" }

    [notify]
    title_info  = { fg = "${t.green}" }
    title_warn  = { fg = "${t.yellow}" }
    title_error = { fg = "${t.red}" }

    [filetype]
    rules = [
      { mime = "**/image/*", fg = "${t.cyan}" },
      { mime = "**/{audio,video}/*", fg = "${t.yellow}" },
      { mime = "**/application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}", fg = "${t.purple}" },
      { mime = "**/application/{pdf,doc,rtf}", fg = "${t.green}" },
      { mime = "vfs/{absent,stale}", fg = "${t.dim}" },
      { url = "*", fg = "${t.fg}" },
      { url = "*/", fg = "${t.accent}" },
    ]
  '';

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
