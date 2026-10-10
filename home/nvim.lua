-- Opciones
vim.g.mapleader = " "
local o = vim.opt
o.number = true; o.relativenumber = true; o.cursorline = true
o.expandtab = true; o.shiftwidth = 2; o.tabstop = 2; o.smartindent = true
o.ignorecase = true; o.smartcase = true
o.termguicolors = true; o.signcolumn = "yes"; o.scrolloff = 8
o.clipboard = "unnamedplus"; o.undofile = true; o.updatetime = 250
o.splitright = true; o.splitbelow = true; o.mouse = "a"

-- Tema: Material "deep ocean" sobre negro puro
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

-- Resaltado de sintaxis (treesitter)
vim.api.nvim_create_autocmd("FileType", { callback = function() pcall(vim.treesitter.start) end })

-- UI
require("lualine").setup({ options = { theme = "auto", globalstatus = true } })
require("gitsigns").setup()
require("which-key").setup()
require("oil").setup()
require("nvim-autopairs").setup()

-- Atajos
local map = vim.keymap.set
local tb = require("telescope.builtin")
map("n", "<leader>ff", tb.find_files, { desc = "Buscar archivos" })
map("n", "<leader>fg", tb.live_grep, { desc = "Buscar texto" })
map("n", "<leader>fb", tb.buffers, { desc = "Buffers" })
map("n", "<leader>fh", tb.help_tags, { desc = "Ayuda" })
map("n", "-", "<cmd>Oil<cr>", { desc = "Explorador de archivos" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Guardar" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Salir" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Autocompletado
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

-- LSP (los servidores los instala Nix)
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

-- Notas en Markdown (compatible con una bóveda de Obsidian) en ~/Notas
vim.opt.conceallevel = 2
pcall(function() require("render-markdown").setup({}) end)
local ok = pcall(function()
  require("obsidian").setup({
    workspaces = { { name = "notas", path = "~/Notas" } },
    notes_subdir = "inbox",
    daily_notes = { folder = "diario" },
    completion = { nvim_cmp = true, min_chars = 2 },
    picker = { name = "telescope.nvim" },
    ui = { enable = false }, -- lo dibuja render-markdown
  })
end)
if ok then
  local function ob(sub, legacy)
    return function()
      if vim.fn.exists(":Obsidian") == 2 then vim.cmd("Obsidian " .. sub) else vim.cmd(legacy) end
    end
  end
  map("n", "<leader>on", ob("new", "ObsidianNew"), { desc = "Nota nueva" })
  map("n", "<leader>of", ob("quick_switch", "ObsidianQuickSwitch"), { desc = "Buscar nota" })
  map("n", "<leader>os", ob("search", "ObsidianSearch"), { desc = "Buscar en notas" })
  map("n", "<leader>ob", ob("backlinks", "ObsidianBacklinks"), { desc = "Backlinks" })
  map("n", "<leader>ol", ob("links", "ObsidianLinks"), { desc = "Enlaces de la nota" })
  map("n", "<leader>od", ob("today", "ObsidianToday"), { desc = "Nota de hoy" })
end

-- Pantalla de inicio
vim.opt.shortmess:append("I")
vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#82aaff" })
vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#546e7a", italic = true })
local ok_alpha = pcall(function()
  local d = require("alpha.themes.dashboard")
  d.section.header.val = {
    [[                                              ]],
    [[   _   _ _      ___  ____                     ]],
    [[  | \ | (_)_  _/ _ \/ ___|                    ]],
    [[  |  \| | \ \/ / | | \___ \                   ]],
    [[  | |\  | |>  <| |_| |___) |                  ]],
    [[  |_| \_|_/_/\_\\___/|____/                   ]],
    [[                                              ]],
  }
  d.section.header.opts.hl = "AlphaHeader"
  d.section.buttons.val = {
    d.button("e", "  Nuevo archivo", "<cmd>ene | startinsert<CR>"),
    d.button("f", "  Buscar archivo", "<cmd>Telescope find_files<CR>"),
    d.button("r", "  Archivos recientes", "<cmd>Telescope oldfiles<CR>"),
    d.button("g", "  Buscar texto", "<cmd>Telescope live_grep<CR>"),
    d.button("n", "  Notas", "<cmd>Oil ~/Notas<CR>"),
    d.button("c", "  Configuración (nix-conf)", "<cmd>Oil ~/nix-conf<CR>"),
    d.button("q", "  Salir", "<cmd>qa<CR>"),
  }
  d.section.footer.val = "manssell@t420  ·  NixOS"
  d.section.footer.opts.hl = "AlphaFooter"
  require("alpha").setup(d.config)
end)
