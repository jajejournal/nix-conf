-- Options
vim.g.mapleader = " "
local o = vim.opt
o.number = true; o.relativenumber = true; o.cursorline = true
o.expandtab = true; o.shiftwidth = 2; o.tabstop = 2; o.smartindent = true
o.ignorecase = true; o.smartcase = true
o.termguicolors = true; o.signcolumn = "yes"; o.scrolloff = 8
o.clipboard = "unnamedplus"; o.undofile = true; o.updatetime = 250
o.splitright = true; o.splitbelow = true; o.mouse = "a"

-- Theme: Material "deep ocean" on pure black
vim.g.material_style = "deep ocean"
pcall(function() require("material").setup({ disable = { background = true } }) end)
local function black()
  for _, g in ipairs({ "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer", "LineNr", "FloatBorder" }) do
    local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
    hl.bg = "#000000"
    vim.api.nvim_set_hl(0, g, hl)
  end
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = black })
pcall(vim.cmd.colorscheme, "material")
black()

-- Syntax highlighting (treesitter)
vim.api.nvim_create_autocmd("FileType", { callback = function() pcall(vim.treesitter.start) end })

-- UI
require("lualine").setup({ options = { theme = "auto", globalstatus = true } })
require("gitsigns").setup()
require("which-key").setup()
require("oil").setup()
require("nvim-autopairs").setup()

-- Shortcuts
local map = vim.keymap.set
local tb = require("telescope.builtin")
map("n", "<leader>ff", tb.find_files, { desc = "Find files" })
map("n", "<leader>fg", tb.live_grep, { desc = "Search text" })
map("n", "<leader>fb", tb.buffers, { desc = "Buffers" })
map("n", "<leader>fh", tb.help_tags, { desc = "Help" })
map("n", "-", "<cmd>Oil<cr>", { desc = "File explorer" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Completion
local cmp, luasnip = require("cmp"), require("luasnip")
cmp.setup({
  snippet = { expand = function(a) luasnip.lsp_expand(a.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = { { name = "nvim_lsp" }, { name = "luasnip" }, { name = "path" }, { name = "buffer" } },
})

-- LSP (servers are installed by Nix)
vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
vim.lsp.config("lua_ls", { settings = { Lua = { diagnostics = { globals = { "vim" } } } } })
vim.lsp.enable({
  "pyright", "ts_ls", "jdtls", "sqls", "gopls", "clangd", "rust_analyzer",
  "nil_ls", "lua_ls", "bashls", "html", "cssls", "jsonls", "yamlls", "marksman",
})
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local b = { buffer = ev.buf }
    map("n", "gd", vim.lsp.buf.definition, b)
    map("n", "K", vim.lsp.buf.hover, b)
    map("n", "<leader>rn", vim.lsp.buf.rename, b)
    map("n", "<leader>ca", vim.lsp.buf.code_action, b)
    map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, b)
    map("n", "<leader>e", vim.diagnostic.open_float, b)
  end,
})
vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- Notes in Markdown (Obsidian-compatible vault) in ~/Notes
vim.opt.conceallevel = 2
pcall(function() require("render-markdown").setup({}) end)
local ok = pcall(function()
  require("obsidian").setup({
    workspaces = { { name = "notes", path = "~/Notes" } },
    notes_subdir = "inbox",
    daily_notes = { folder = "daily" },
    completion = { nvim_cmp = true, min_chars = 2 },
    picker = { name = "telescope.nvim" },
    ui = { enable = false }, -- rendered by render-markdown
  })
end)
if ok then
  local function ob(sub, legacy)
    return function()
      if vim.fn.exists(":Obsidian") == 2 then vim.cmd("Obsidian " .. sub) else vim.cmd(legacy) end
    end
  end
  map("n", "<leader>on", ob("new", "ObsidianNew"), { desc = "New note" })
  map("n", "<leader>of", ob("quick_switch", "ObsidianQuickSwitch"), { desc = "Find note" })
  map("n", "<leader>os", ob("search", "ObsidianSearch"), { desc = "Search notes" })
  map("n", "<leader>ob", ob("backlinks", "ObsidianBacklinks"), { desc = "Backlinks" })
  map("n", "<leader>ol", ob("links", "ObsidianLinks"), { desc = "Note links" })
  map("n", "<leader>od", ob("today", "ObsidianToday"), { desc = "Today's note" })
end

-- Start screen
vim.opt.shortmess:append("I")
vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#82aaff" })
vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#546e7a", italic = true })
local ok_alpha = pcall(function()
  local d = require("alpha.themes.dashboard")
  d.section.header.val = {
    [[                                              ]],
    [[   _   _ _      ___  ____                     ]],
    [[  | \ | (_) _  / _ \/ ___|                    ]],
    [[  |  \| | \ \/ / | | \___ \                   ]],
    [[  | |\  | |>  <| |_| |___) |                  ]],
    [[  |_| \_|_/_/\_\\___/|____/                   ]],
    [[                                              ]],
  }
  d.section.header.opts.hl = "AlphaHeader"
  d.section.buttons.val = {
    d.button("e", "  New file", "<cmd>ene | startinsert<CR>"),
    d.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
    d.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
    d.button("g", "  Search text", "<cmd>Telescope live_grep<CR>"),
    d.button("n", "  Notes", "<cmd>Oil ~/Notes<CR>"),
    d.button("c", "  Config (nix-conf)", "<cmd>Oil ~/nix-conf<CR>"),
    d.button("q", "  Quit", "<cmd>qa<CR>"),
  }
  d.section.footer.val = "manssell@t420  ·  NixOS"
  d.section.footer.opts.hl = "AlphaFooter"
  require("alpha").setup(d.config)
end)
