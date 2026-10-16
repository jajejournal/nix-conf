# Neovim como IDE. Los plugins y los servidores LSP/formatters los instala Nix
# (no hay Mason). El comportamiento está en home/nvim.lua
{ pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # --- Tema / interfaz ---
      github-nvim-theme
      lualine-nvim
      nvim-web-devicons
      bufferline-nvim
      nvim-navic            # "breadcrumbs" (ruta del símbolo) desde el LSP
      indent-blankline-nvim
      which-key-nvim
      alpha-nvim

      # --- Resaltado / edición de código ---
      (nvim-treesitter.withAllGrammars)
      nvim-treesitter-textobjects
      nvim-autopairs
      comment-nvim
      nvim-surround
      flash-nvim

      # --- Explorador de archivos (columna izquierda) ---
      neo-tree-nvim
      nui-nvim          # dependencia de neo-tree
      oil-nvim          # edición de carpetas como un buffer

      # --- Búsqueda ---
      telescope-nvim
      plenary-nvim
      telescope-fzf-native-nvim

      # --- LSP + autocompletado ---
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip

      # --- Git ---
      gitsigns-nvim
      neogit
      diffview-nvim

      # --- Terminal y depurador (lo que faltaba para ser IDE) ---
      toggleterm-nvim
      nvim-dap
      nvim-dap-ui
      nvim-nio            # dependencia de nvim-dap-ui
      nvim-dap-virtual-text

      # --- Markdown / notas ---
      obsidian-nvim
      render-markdown-nvim

      # --- Diagnóstico y formato ---
      conform-nvim
      trouble-nvim
    ];

    # Servidores LSP, formatters y depuradores (todos desde Nix).
    extraPackages = with pkgs; [
      # LSP: Python, JS/TS, Java, SQL, Go, C/C++, Rust, Nix, Lua, Bash, web, YAML, Markdown
      pyright
      typescript-language-server
      jdt-language-server
      sqls
      gopls
      clang-tools           # clangd + clang-format
      rust-analyzer
      nil
      lua-language-server
      bash-language-server
      vscode-langservers-extracted
      yaml-language-server
      marksman

      # Formatters
      black
      prettier
      stylua
      shfmt
      nixfmt
      go
      rustfmt

      # Depurador (DAP)
      (python3.withPackages (ps: [ ps.debugpy ])) # Python
      delve                                      # Go

      # Utilidades usadas por los plugins
      ripgrep
      fd
      xclip
    ];

    initLua = lib.fileContents ./nvim.lua;
  };
}
