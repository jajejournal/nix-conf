# Neovim as an IDE. The plugins and the LSP servers/formatters are installed by
# Nix (there is no Mason). The behavior lives in home/nvim.lua
{ pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # --- Theme / interface ---
      github-nvim-theme
      lualine-nvim
      nvim-web-devicons
      bufferline-nvim
      nvim-navic            # "breadcrumbs" (symbol path) from the LSP
      indent-blankline-nvim
      which-key-nvim
      alpha-nvim

      # --- Highlighting / code editing ---
      (nvim-treesitter.withAllGrammars)
      nvim-treesitter-textobjects
      nvim-autopairs
      comment-nvim
      nvim-surround
      flash-nvim

      # --- File explorer (left column) ---
      neo-tree-nvim
      nui-nvim          # neo-tree dependency
      oil-nvim          # edit folders as a buffer

      # --- Search ---
      telescope-nvim
      plenary-nvim
      telescope-fzf-native-nvim

      # --- LSP + completion ---
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

      # --- Terminal and debugger (what was missing to be an IDE) ---
      toggleterm-nvim
      nvim-dap
      nvim-dap-ui
      nvim-nio            # nvim-dap-ui dependency
      nvim-dap-virtual-text

      # --- Markdown / notes ---
      obsidian-nvim
      render-markdown-nvim

      # --- Diagnostics and formatting ---
      conform-nvim
      trouble-nvim
    ];

    # LSP servers, formatters and debuggers (all from Nix).
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

      # Debugger (DAP)
      (python3.withPackages (ps: [ ps.debugpy ])) # Python
      delve                                      # Go

      # Utilities used by the plugins
      ripgrep
      fd
      xclip
    ];

    initLua = lib.fileContents ./nvim.lua;
  };
}
