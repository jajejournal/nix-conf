-- Options
vim.g.mapleader = " "
local o = vim.opt
o.number = true
o.relativenumber = true
o.cursorline = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.termguicolors = true
o.signcolumn = "yes"
o.scrolloff = 8
o.clipboard = "unnamedplus"
o.undofile = true
o.updatetime = 250
o.splitright = true
o.splitbelow = true
o.mouse = "a"

-- Theme:  Custom GitHub Dark with pure black and exact palette
require("github-theme").setup({
	options = {
		compile_path = vim.fn.stdpath("cache") .. "/github-theme",
		compile_file_suffix = "_compiled",
		hide_inactive_statusline = false,
		transparent = false,
		terminal_colors = true,
		background = {
			dark = "default",
			light = "light",
		},
	},
	specs = {
		all = {
			syntax = {
				string = "#3fb950", -- green
				number = "#ffa657", -- orange
				boolean = "#ffa657", -- orange
				func = "#e3b341", -- yellow
				keyword = "#ff7b72", -- red
				type = "#58a6ff", -- blue
				identifier = "#bc8cff", -- purple
				operator = "#56d4dd", -- cyan
				comment = "#8b949e", -- dim
			},
			uv = {
				bg = "#000000", -- Fondo negro puro
				bgAlt = "#0a0a0a",
				surface = "#1a1a1a",
				fg = "#e6edf3",
				syntax = "#e6edf3",
			},
		},
	},
	groups = {
		all = {
			Normal = { fg = "#e6edf3", bg = "#000000" },
			NormalNC = { fg = "#e6edf3", bg = "#0a0a0a" },
			NormalFloat = { fg = "#e6edf3", bg = "#1a1a1a" },
			SignColumn = { bg = "#000000" },
			EndOfBuffer = { fg = "#333333", bg = "#000000" },
			LineNr = { fg = "#8b949e", bg = "#000000" },
			CursorLineNr = { fg = "#ffffff", bold = true },
			FloatBorder = { fg = "#8b949e", bg = "#1a1a1a" },
			Pmenu = { fg = "#e6edf3", bg = "#1a1a1a" },
			PmenuSel = { fg = "#000000", bg = "#ffffff" },
		},
	},
})

vim.cmd.colorscheme("github_dark_default")

-- Syntax highlighting (treesitter)
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

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
	snippet = {
		expand = function(a)
			luasnip.lsp_expand(a.body)
		end,
	},
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
	"pyright",
	"ts_ls",
	"jdtls",
	"sqls",
	"gopls",
	"clangd",
	"rust_analyzer",
	"nil_ls",
	"lua_ls",
	"bashls",
	"html",
	"cssls",
	"jsonls",
	"yamlls",
	"marksman",
})
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local b = { buffer = ev.buf }
		map("n", "gd", vim.lsp.buf.definition, b)
		map("n", "K", vim.lsp.buf.hover, b)
		map("n", "<leader>rn", vim.lsp.buf.rename, b)
		map("n", "<leader>ca", vim.lsp.buf.code_action, b)
		map("n", "<leader>e", vim.diagnostic.open_float, b)
	end,
})
vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- Notes in Markdown (Obsidian-compatible vault) in ~/Notes
vim.opt.conceallevel = 2
pcall(function()
	require("render-markdown").setup({})
end)
local obs_ok = pcall(function()
	require("obsidian").setup({
		workspaces = { { name = "notes", path = "~/Notes" } },
		notes_subdir = "inbox",
		daily_notes = { folder = "daily" },
		completion = { nvim_cmp = true, min_chars = 2 },
		picker = { name = "telescope.nvim" },
		ui = { enable = false }, -- rendered by render-markdown
	})
end)
if obs_ok then
	local function ob(sub, legacy)
		return function()
			if vim.fn.exists(":Obsidian") == 2 then
				vim.cmd("Obsidian " .. sub)
			else
				vim.cmd(legacy)
			end
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
vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#58a6ff" })
vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#8b949e", italic = true })
local ok_alpha = pcall(function()
	local d = require("alpha.themes.dashboard")
	d.section.header.val = {
		[[                                              ]],
		[[   _   _ _       ___  ____                    ]],
		[[  | \ | (_) _   / _ \/ ___|                   ]],
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

-- Formateo automático al guardar
require("conform").setup({
	formatters_by_ft = {
		python = { "black" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		["javascriptreact"] = { "prettier" },
		["typescriptreact"] = { "prettier" },
		json = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		lua = { "stylua" },
		sh = { "shfmt" },
		nix = { "nixfmt" },
		go = { "gofmt" },
		rust = { "rustfmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
	},
	format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
})
vim.keymap.set("n", "<leader>cf", function()
	require("conform").format({ lsp_format = "fallback" })
end, { desc = "Format file" })

-- Diagnostics panel (Trouble v3)
require("trouble").setup()
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Workspace diagnostics" })
vim.keymap.set("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Document diagnostics" })
