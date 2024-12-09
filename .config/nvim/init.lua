-- {{{ [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = false

-- Enable mouse mode
vim.o.mouse = ""

-- Enable break indent
vim.o.breakindent = false

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "auto"

-- Set colorscheme
vim.o.termguicolors = true

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- }}}

-- {{{ [[ Basic Keymaps ]]
-- Set \ as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
-- this seems to matter when <Space> is leader key
-- vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap (so that j/k default to going up/down a word-wrapped line)
-- vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- useful maps
vim.keymap.set("n", "\\l", ":IndentBlanklineToggle<CR>")
vim.keymap.set("n", "\\c", ":close<CR>")
-- close all windows except active - won't autowrite as long as you don't fuck
-- with hidden and autowrite, always use the vim-sensible
vim.keymap.set("n", "\\o", ":only<CR>")
vim.keymap.set("n", "\\s", ":tab split<CR>")

-- useful to rearrange tabs
-- i wanted to use \n and \p for next and prev
-- but i went with (p)rev and undo (P)rev
-- so i can keep \n for numbers
vim.keymap.set("n", "\\p", ":-tabmove<CR>")
vim.keymap.set("n", "\\P", ":+tabmove<CR>")
vim.keymap.set("n", "\\[", ":-tabmove<CR>")
vim.keymap.set("n", "\\]", ":+tabmove<CR>")

-- easy tab switching
vim.keymap.set("n", "\\1", ":tabn 1<CR>")
vim.keymap.set("n", "\\2", ":tabn 2<CR>")
vim.keymap.set("n", "\\3", ":tabn 3<CR>")
vim.keymap.set("n", "\\4", ":tabn 4<CR>")
vim.keymap.set("n", "\\5", ":tabn 5<CR>")
vim.keymap.set("n", "\\6", ":tabn 6<CR>")
vim.keymap.set("n", "\\7", ":tabn 7<CR>")
vim.keymap.set("n", "\\8", ":tabn 8<CR>")
vim.keymap.set("n", "\\9", ":tabn 9<CR>")
vim.keymap.set("n", "\\0", ":tabn 0<CR>")

-- faster quit
vim.keymap.set("n", "\\q", ":q<CR>")

-- courtesy of JoshTriplett:
--   https://news.ycombinator.com/item?id=40839361
vim.keymap.set("n", "\\.", ":Texplore<CR>")
vim.keymap.set("n", "\\v", ":Vexplore<CR>")

-- convenient to open a new tab instead of :tabnew
vim.keymap.set("n", "\\t", ":tabnew<CR>")

-- toggle line numbers
vim.keymap.set("n", "\\n", ":set nu!<CR>")

-- toggle gutter/signcolumn
vim.keymap.set("n", "\\g", function()
	vim.wo.signcolumn = vim.wo.signcolumn == "no" and "yes" or "no"
end)

-- lsp format
vim.keymap.set("n", "\\f", ":lua require('conform').format()<CR>")

-- }}}

-- {{{ [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})
-- }}}

-- {{{ [[ default tabstops ]]
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		vim.opt_local.tabstop = 4
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function()
		vim.opt_local.tabstop = 2
	end,
})
-- }}}

-- {{{ [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)
-- }}}

-- {{{ [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require("lazy").setup({
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},
	{
		"nvim-lualine/lualine.nvim", -- Fancier statusline
		opts = {
			options = {
				icons_enabled = false,
				theme = "onedark",
				component_separators = "|",
				section_separators = "",
			},
		},
	},
	{ -- LSP Configuration & Plugins
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			{ "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by nvim-cmp
			"hrsh7th/cmp-nvim-lsp",

			{
				-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
				-- used for completion, annotations and signatures of Neovim apis
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = {
						-- Load luvit types when the `vim.uv` word is found
						{ path = "luvit-meta/library", words = { "vim%.uv" } },
					},
				},
			},
		},
	},

	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		dependencies = {
			"L3MON4D3/LuaSnip",
			build = (function()
				-- Build Step is needed for regex support in snippets.
				-- This step is not supported in many windows environments.
				-- Remove the below condition to re-enable on windows.
				if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
					return
				end
				return "make install_jsregexp"
			end)(),

			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function()
			-- nvim-cmp setup
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = {
					{
						name = "lazydev",
						-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
						group_index = 0,
					},
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				},
			})
		end,
	},

	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
	},

	-- Autoformatting
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				python = { "isort", "black" },
				-- You can customize some of the format options for the filetype (:help conform.format)
				rust = { "rustfmt", lsp_format = "fallback" },
				-- Conform will run the first available formatter
				javascript = { "prettierd", "prettier", stop_after_first = true },
				-- Conform for gopls
				go = { "goimports", "gofumpt" },
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				-- timeout for 10s for mac where first exec of binary
				-- takes awhile
				timeout_ms = 10000,
				lsp_format = "fallback",
			},
		},
	},

	-- Git related plugins
	"tpope/vim-fugitive",

	"nnathan/desertrocks",
	"numToStr/Comment.nvim", -- "gc" to comment visual regions/lines

	-- Fuzzy Finder (files, lsp, etc)
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			"nvim-telescope/telescope-ui-select.nvim",
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
	},
})
-- }}}

-- Set lualine as statusline
-- See `:help lualine.txt`
--require("lualine").setup({
--	options = {
--		icons_enabled = false,
--		theme = "onedark",
--		component_separators = "|",
--		section_separators = "",
--	},
--})

-- Enable Comment.nvim
require("Comment").setup()

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<C-u>"] = false,
				["<C-d>"] = false,
			},
		},
	},
})

-- Enable telescope fzf native, if installed
pcall(require("telescope").load_extension, "fzf")

-- See `:help telescope.builtin`
vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer]" })

vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>gs", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>lg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup({
	-- Add languages to be installed here that you want installed for treesitter
	ensure_installed = { "c", "cpp", "go", "lua", "python", "rust", "tsx", "typescript", "vimdoc", "vim" },
	auto_install = false,

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
	},
	indent = { enable = true, disable = { "python" } },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<c-space>",
			node_incremental = "<c-space>",
			scope_incremental = "<c-s>",
			node_decremental = "<c-backspace>",
		},
	},
})

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
	-- NOTE: Remember that lua is a real programming language, and as such it is possible
	-- to define small helper and utility functions so you don't have to repeat yourself
	-- many times.
	--
	-- In this case, we create a function that lets us more easily define mappings specific
	-- for LSP related items. It sets the mode, buffer and description for us each time.
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

	nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
	nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
	nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
	nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
	nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

	-- See `:help K` for why this keymap
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

	-- Lesser used LSP functionality
	nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
	nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
	nmap("<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "[W]orkspace [L]ist Folders")

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		require("conform").format()
	end, { desc = "Format current buffer with LSP" })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
	clangd = {},
	gopls = {},
	rust_analyzer = {},
	pylsp = {},
	vimls = {},

	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Setup mason so it can manage external tooling
require("mason").setup()

-- Ensure the servers above are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers or {}),
})

mason_lspconfig.setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
		})
	end,
})

local ensure_installed = vim.tbl_keys(servers or {})

vim.list_extend(ensure_installed, {
	"black",
	"isort",
	"stylua",
	"shellcheck",
	"gofumpt",
	"goimports",
	"rust-analyzer",
	"shfmt",
	"stylua",
})

require("mason-tool-installer").setup({

	-- a list of all tools you want to ensure are installed upon
	-- start
	ensure_installed = ensure_installed,

	-- if set to true this will check each tool for updates. If updates
	-- are available the tool will be updated. This setting does not
	-- affect :MasonToolsUpdate or :MasonToolsInstall.
	-- Default: false
	auto_update = false,

	-- automatically install / update on startup. If set to false nothing
	-- will happen on startup. You can use :MasonToolsInstall or
	-- :MasonToolsUpdate to install tools and check for updates.
	-- Default: true
	run_on_start = true,

	-- set a delay (in ms) before the installation starts. This is only
	-- effective if run_on_start is set to true.
	-- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
	-- Default: 0
	start_delay = 0,

	-- Only attempt to install if 'debounce_hours' number of hours has
	-- elapsed since the last time Neovim was started. This stores a
	-- timestamp in a file named stdpath('data')/mason-tool-installer-debounce.
	-- This is only relevant when you are using 'run_on_start'. It has no
	-- effect when running manually via ':MasonToolsInstall' etc....
	-- Default: nil
	debounce_hours = 1, -- at least 5 hours between attempts to install/update

	-- By default all integrations are enabled. If you turn on an integration
	-- and you have the required module(s) installed this means you can use
	-- alternative names, supplied by the modules, for the thing that you want
	-- to install. If you turn off the integration (by setting it to false) you
	-- cannot use these alternative names. It also suppresses loading of those
	-- module(s) (assuming any are installed) which is sometimes wanted when
	-- doing lazy loading.
	integrations = {
		["mason-lspconfig"] = true,
	},
})

vim.g.diagnostics_active = true

function _G.toggle_diagnostics()
	if vim.g.diagnostics_active then
		vim.g.diagnostics_active = false
		vim.diagnostic.enable(false)
	else
		vim.g.diagnostics_active = true
		vim.diagnostic.enable()
	end
end

vim.api.nvim_set_keymap("n", "\\d", ":call v:lua.toggle_diagnostics()<CR>", { noremap = true, silent = true })

vim.api.nvim_set_hl(0, "@lsp.type.comment.cpp", {})

-- {{{ [[pmenu colours]]
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	command = "highlight Pmenu ctermbg=60 ctermfg=81 guibg=MediumPurple4 guifg=SteelBlue1",
})
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	command = "highlight PmenuSel ctermbg=60 ctermfg=50 guibg=MediumPurple4 guifg=Cyan2",
})
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	command = "highlight Search ctermbg=24 ctermfg=49 guibg=DeepSkyBlue4 guifg=MediumSpringGreen",
})
-- }}}

-- {{{ [[tabmenu colours]]
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	command = "highlight TabLineFill ctermbg=DarkGreen ctermfg=LightGreen guibg=NvimDarkGreen guifg=DarkGreen",
})

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	command = "highlight TabLine ctermbg=DarkGreen ctermfg=LightGreen guibg=Grey23 guifg=DarkSeaGreen",
})

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	command = "highlight TabLineSel ctermbg=DarkGreen ctermfg=LightGreen guibg=DeepSkyBlue4 guifg=Yellow3",
})
-- }}}

-- {{{ [[whitespace]]
local whitespace_ag = vim.api.nvim_create_augroup("show_whitespace", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter" }, {
	pattern = "*",
	group = whitespace_ag,
	command = [[ syntax match Tab /\v\t/ containedin=ALL | syntax match TrailingWS /\v\s\ze\s*$/ containedin=ALL ]],
})
vim.cmd.highlight({ "Tab", "ctermfg=234 guibg=Grey40" })
vim.cmd.highlight({ "TrailingWS", "ctermfg=203 guibg=IndianRed1" })
-- }}}

vim.cmd.colorscheme("default")

-- vim: foldmethod=marker foldmarker={{{,}}}
