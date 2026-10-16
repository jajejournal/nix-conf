-- ============================================================================
--  Neovim as an IDE  ·  NixOS (home-manager)
--  The plugins and the LSP/formatter/debugger servers are installed by Nix
--  (see home/nvim.nix). Here we only define the behavior.
--
--  Key shortcuts (leader = Space):
--    <leader>e    open/close the file tree (left column)
--    <leader>ff   find files           <leader>fg  search text
--    <leader>gg   lazygit              <leader>gn  neogit (git panel)
--    <C-\>        floating terminal    <leader>tt  floating terminal
--    <F5>         debug/continue       <leader>db  set/remove breakpoint
--    <leader>du   debugger panel       <leader>xx  project diagnostics
--    <leader>fe   focus sidebar        <leader>ld  line diagnostics
-- ============================================================================

local map = vim.keymap.set
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ---------------------------------------------------------------- Options ---
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
o.wrap = false
o.showmode = false
o.completeopt = { "menu", "menuone", "noselect" }
-- Rounded borders on floating windows (Neovim 0.11+)
if vim.fn.has("nvim-0.11") == 1 then
	vim.o.winborder = "rounded"
end

-- ------------------------------------------------------------------- Theme ---
require("github-theme").setup({
	options = {
		compile_path = vim.fn.stdpath("cache") .. "/github-theme",
		compile_file_suffix = "_compiled",
		hide_inactive_statusline = false,
		transparent = false,
		terminal_colors = true,
		background = { dark = "default", light = "light" },
	},
	specs = {
		all = {
			syntax = {
				string = "#3fb950",
				number = "#ffa657",
				boolean = "#ffa657",
				func = "#e3b341",
				keyword = "#ff7b72",
				type = "#58a6ff",
				identifier = "#bc8cff",
				operator = "#56d4dd",
				comment = "#8b949e",
			},
			uv = {
				bg = "#000000",
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
			PmenuKind = { fg = "#58a6ff", bg = "#1a1a1a" },
			PmenuSbar = { bg = "#1a1a1a" },
			PmenuThumb = { bg = "#8b949e" },
			WinSeparator = { fg = "#1a1a1a", bg = "#000000" },
			CursorLine = { bg = "#0a0a0a" },
		},
	},
})
vim.cmd.colorscheme("github_dark_default")

-- ----------------------------------------------------------- Treesitter -----
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
	end,
})
-- Textobjects (select whole functions/classes, etc.)
pcall(function()
	require("nvim-treesitter-textobjects").setup({})
	local ts = require("nvim-treesitter-textobjects.select")
	map({ "x", "o" }, "af", function()
		ts.select_textobject("@function.outer", "textobjects")
	end, { desc = "Outer function" })
	map({ "x", "o" }, "if", function()
		ts.select_textobject("@function.inner", "textobjects")
	end, { desc = "Inner function" })
	map({ "x", "o" }, "ac", function()
		ts.select_textobject("@class.outer", "textobjects")
	end, { desc = "Outer class" })
	map({ "x", "o" }, "ic", function()
		ts.select_textobject("@class.inner", "textobjects")
	end, { desc = "Inner class" })
end)

-- ========================================================= FILE TREE ========
-- neo-tree: left column with folders
require("neo-tree").setup({
	close_if_last_window = true,
	window = { width = 34 },
	filesystem = {
		follow_current_file = { enabled = true },
		hijack_netrw_behavior = "open_current",
	},
})
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "File explorer" })
map("n", "<leader>fe", "<cmd>Neotree focus<cr>", { desc = "Focus explorer" })
map("n", "-", "<cmd>Oil<cr>", { desc = "Open current folder (oil)" })
require("oil").setup()

-- ============================================================= SEARCH =======
local tb = require("telescope.builtin")
require("telescope").setup({})
map("n", "<leader>ff", tb.find_files, { desc = "Find files" })
map("n", "<leader>fg", tb.live_grep, { desc = "Search text" })
map("n", "<leader>fb", tb.buffers, { desc = "Buffers" })
map("n", "<leader>fh", tb.help_tags, { desc = "Help" })
map("n", "<leader>fr", tb.oldfiles, { desc = "Recent" })
map("n", "<leader>/", tb.current_buffer_fuzzy_find, { desc = "Search in file" })

-- ========================================================= COMPLETION ======
local cmp, luasnip = require("cmp"), require("luasnip")
cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "path" },
		{ name = "buffer" },
	},
})

-- =================================================================== LSP =====
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
		map("n", "gD", vim.lsp.buf.declaration, b)
		map("n", "gr", tb.lsp_references, b)
		map("n", "gi", tb.lsp_implementations, b)
		map("n", "K", vim.lsp.buf.hover, b)
		map("n", "<leader>rn", vim.lsp.buf.rename, b)
		map("n", "<leader>ca", vim.lsp.buf.code_action, b)
		map("n", "<leader>ld", vim.diagnostic.open_float, b)
		-- breadcrumbs
		if ev.data and ev.data.client_id then
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if client and client.server_capabilities.documentSymbolProvider then
				require("nvim-navic").attach(client, ev.buf)
			end
		end
	end,
})
vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- =================================================================== GIT =====
require("gitsigns").setup()
require("neogit").setup({})
map("n", "<leader>gn", "<cmd>Neogit<cr>", { desc = "Git panel (neogit)" })
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { desc = "File diff" })
map("n", "<leader>gg", function()
	require("toggleterm").exec("lazygit")
end, { desc = "lazygit" })
map("n", "<leader>gv", "<cmd>DiffviewOpen<cr>", { desc = "Diffview" })

-- ============================================== TERMINAL INSIDE NVIM ========
require("toggleterm").setup({
	size = 15,
	open_mapping = [[<C-\>]],
	direction = "float",
	float_opts = { border = "curved" },
	shade_terminals = false,
})
map("n", "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", { desc = "Floating terminal" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal at the bottom" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical size=70<cr>", { desc = "Terminal on the right" })
-- Leave terminal mode with Esc
vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "term://*",
	callback = function()
		map("t", "<Esc>", [[<C-\><C-n>]], { buffer = 0 })
	end,
})

-- ============================================================== DEBUGGER ====
local dap = require("dap")
local dapui = require("dapui")
dapui.setup()
require("nvim-dap-virtual-text").setup({})

-- Python (uses debugpy, installed by Nix)
dap.adapters.python = {
	type = "executable",
	command = "python3",
	args = { "-m", "debugpy.adapter" },
}
dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch the current file",
		program = "${file}",
		console = "integratedTerminal",
	},
}

-- Go (uses dlv, installed by Nix)
dap.adapters.go = {
	type = "server",
	port = "${port}",
	executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
}
dap.configurations.go = {
	{ type = "go", name = "Debug the current file", request = "launch", program = "${file}" },
}

map("n", "<F5>", dap.continue, { desc = "Debug / continue" })
map("n", "<F10>", dap.step_over, { desc = "Step over" })
map("n", "<F11>", dap.step_into, { desc = "Step into" })
map("n", "<F12>", dap.step_out, { desc = "Step out" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Breakpoint" })
map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "Conditional breakpoint" })
map("n", "<leader>dc", dap.continue, { desc = "Continue" })
map("n", "<leader>du", dapui.toggle, { desc = "Debugger panel" })
map("n", "<leader>dr", dap.repl.toggle, { desc = "Debugger REPL" })
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- ============================================================== BUFFERS =====
require("bufferline").setup({})
map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- ================================================================ EDIT ======
require("nvim-autopairs").setup()
require("Comment").setup()
require("nvim-surround").setup()
require("flash").setup()
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- =========================================================== INTERFACE ======
require("lualine").setup({
	options = { theme = "auto", globalstatus = true },
})
require("ibl").setup()
require("which-key").setup({})

-- ======================================================= MARKDOWN / NOTES ==
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
		ui = { enable = false },
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
	map("n", "<leader>ol", ob("links", "ObsidianLinks"), { desc = "Links" })
	map("n", "<leader>od", ob("today", "ObsidianToday"), { desc = "Today's note" })
end

-- ========================================================== START SCREEN ===
vim.opt.shortmess:append("I")
vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#58a6ff" })
vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#8b949e", italic = true })
pcall(function()
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
		d.button("e", "   New file", "<cmd>ene | startinsert<CR>"),
		d.button("f", "   Find file", "<cmd>Telescope find_files<CR>"),
		d.button("r", "   Recent", "<cmd>Telescope oldfiles<CR>"),
		d.button("g", "   Search text", "<cmd>Telescope live_grep<CR>"),
		d.button("n", "   Notes", "<cmd>Oil ~/Notes<CR>"),
		d.button("c", "   Config (nix-conf)", "<cmd>Oil ~/nix-conf<CR>"),
		d.button("q", "   Quit", "<cmd>qa<CR>"),
	}
	d.section.footer.val = "NixOS"
	d.section.footer.opts.hl = "AlphaFooter"
	require("alpha").setup(d.config)
end)

-- ===================================================== FORMAT ON SAVE =======
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
map("n", "<leader>cf", function()
	require("conform").format({ lsp_format = "fallback" })
end, { desc = "Format file" })

-- ========================================================== DIAGNOSTICS =====
require("trouble").setup()
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Project diagnostics" })
map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "File diagnostics" })
map("n", "<leader>xs", "<cmd>Trouble symbols toggle<cr>", { desc = "File symbols" })
