{ pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      material-nvim
      (nvim-treesitter.withAllGrammars)
      nvim-lspconfig
      nvim-cmp cmp-nvim-lsp cmp-buffer cmp-path luasnip cmp_luasnip
      telescope-nvim plenary-nvim
      lualine-nvim nvim-web-devicons
      gitsigns-nvim which-key-nvim oil-nvim nvim-autopairs
      obsidian-nvim render-markdown-nvim alpha-nvim
    ];
    # Servidores LSP: Python, JS/TS, Java, SQL, Go, C/C++, Rust, Nix, Lua, Bash, web, YAML, Markdown
    extraPackages = with pkgs; [
      pyright typescript-language-server jdt-language-server sqls gopls clang-tools
      rust-analyzer nil lua-language-server bash-language-server
      vscode-langservers-extracted yaml-language-server marksman
      ripgrep fd xclip
    ];
    initLua = lib.fileContents ./nvim.lua;
  };
}
