vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = false
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.scrolloff = 4

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

local editing_feedback = vim.api.nvim_create_augroup("editing_feedback", { clear = true })

vim.api.nvim_create_autocmd("BufReadPost", {
	group = editing_feedback,
	callback = function(event)
		local position = vim.api.nvim_buf_get_mark(event.buf, '"')
		local line = position[1]
		if line > 0 and line <= vim.api.nvim_buf_line_count(event.buf) then
			vim.api.nvim_win_set_cursor(0, position)
		end
	end,
	desc = "Restore the last cursor position",
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = editing_feedback,
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
	desc = "Highlight yanked text",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "c",
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.tabstop = 4
	end,
	desc = "Use four-space indentation for C",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qf", "help", "man", "lspinfo", "checkhealth" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", function()
			if #vim.api.nvim_tabpage_list_wins(0) > 1 then
				vim.cmd.close()
			else
				vim.cmd.bdelete()
			end
		end, { buffer = event.buf, desc = "Close utility buffer", silent = true })
	end,
	desc = "Close utility buffers with q",
})

local lsp_servers = {
	{
		name = "clangd",
		binary = "clangd",
		config = {
			cmd = { "clangd" },
			filetypes = { "c" },
			root_markers = {
				".clangd",
				".clang-tidy",
				".clang-format",
				"compile_commands.json",
				"compile_flags.txt",
				".git",
			},
		},
	},
	{
		name = "pyright",
		binary = "pyright-langserver",
		config = {
			cmd = { "pyright-langserver", "--stdio" },
			filetypes = { "python" },
			root_markers = {
				"pyproject.toml",
				"setup.py",
				"setup.cfg",
				"requirements.txt",
				"Pipfile",
				".git",
			},
			settings = {
				pyright = {
					analysis = {
						autoImportCompletions = false,
						autoSearchPaths = false,
						useLibraryCodeForTypes = false,
						diagnosticMode = "openFilesOnly",
					},
				},
			},
		},
	},
	{
		name = "ruff",
		binary = "ruff",
		config = {
			cmd = { "ruff", "server" },
			filetypes = { "python" },
			root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
		},
	},
}

local function enable_lsp(server)
	if vim.fn.executable(server.binary) == 1 then
		vim.lsp.config(server.name, server.config)
		vim.lsp.enable(server.name)
		return
	end

	vim.api.nvim_create_autocmd("FileType", {
		pattern = server.config.filetypes,
		once = true,
		callback = function()
			vim.notify(
				("Cannot start %s: %s is not executable"):format(server.name, server.binary),
				vim.log.levels.WARN,
				{ title = "LSP" }
			)
		end,
	desc = "Warn when " .. server.name .. " is unavailable",
	})
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local function map(key, action, desc)
			vim.keymap.set("n", key, action, { buffer = event.buf, desc = desc, silent = true })
		end

		map("gd", vim.lsp.buf.definition, "Goto definition")
		map("gD", vim.lsp.buf.declaration, "Goto declaration")
		map("K", function()
			vim.lsp.buf.hover({
				border = "rounded",
				max_width = 72,
				max_height = 18,
				title = " Documentation ",
				title_pos = "center",
			})
		end, "Show hover documentation")
		map("<leader>k", function()
			vim.lsp.buf.signature_help({ border = "rounded" })
		end, "Signature help")

		local function jump_diagnostic(count)
			if vim.bo[event.buf].modified then
				return
			end
			vim.diagnostic.jump({
				count = count,
				on_jump = function()
					vim.diagnostic.open_float({
						bufnr = event.buf,
						border = "single",
						scope = "cursor",
						focus = false,
					})
				end,
			})
		end

		map("[d", function()
			jump_diagnostic(-1)
		end, "Previous diagnostic")
		map("]d", function()
			jump_diagnostic(1)
		end, "Next diagnostic")
		map("<leader>ci", vim.lsp.buf.incoming_calls, "Incoming calls")
		map("<leader>co", vim.lsp.buf.outgoing_calls, "Outgoing calls")
	end,
	desc = "Configure LSP buffer mappings",
})

local lsp_markdown_escapes = vim.api.nvim_create_namespace("lsp_markdown_escapes")

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(event)
		if vim.bo[event.buf].buftype ~= "nofile" then
			return
		end

		vim.api.nvim_buf_clear_namespace(event.buf, lsp_markdown_escapes, 0, -1)
		for row, line in ipairs(vim.api.nvim_buf_get_lines(event.buf, 0, -1, false)) do
			local offset = 1
			while true do
				local start = line:find("\\_", offset, true)
				if not start then
					break
				end
				vim.api.nvim_buf_set_extmark(event.buf, lsp_markdown_escapes, row - 1, start - 1, {
					end_col = start,
					conceal = "",
				})
				offset = start + 2
			end
		end
	end,
	desc = "Conceal escaped underscores in LSP Markdown",
})

vim.diagnostic.config({
	virtual_text = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
	float = {
		border = "single",
		source = "if_many",
	},
	severity_sort = true,
	underline = true,
	update_in_insert = false,
})

vim.api.nvim_create_autocmd({
	"BufModifiedSet",
	"BufReadPost",
	"BufWritePost",
	"DiagnosticChanged",
	"TextChanged",
	"TextChangedI",
	"TextChangedP",
}, {
	callback = function(event)
		vim.diagnostic.enable(not vim.bo[event.buf].modified, { bufnr = event.buf })
	end,
	desc = "Hide diagnostics while a buffer has unsaved changes",
})

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.autoread = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

-- Keep brief operations such as file writes from flashing progress in the terminal UI.
pcall(vim.api.nvim_del_augroup_by_name, "nvim.progress")

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	callback = function()
		vim.schedule(vim.cmd.checktime)
	end,
	desc = "Reload buffers changed outside Neovim",
})

vim.keymap.set({ "n", "i", "v", "o", "c", "t" }, "<C-x><C-s>", function()
	vim.cmd.write()
end, { desc = "Write buffer" })
vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "Write buffer" })
vim.keymap.set("n", "<leader><Tab>", "<cmd>buffer #<CR>", { desc = "Toggle alternate buffer" })
vim.keymap.set("n", "gl", function()
	if vim.bo.modified then
		return
	end
	vim.diagnostic.open_float({ scope = "line" })
end, { desc = "Show line diagnostics" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("c", "<C-g>", "<C-c>")
vim.keymap.set("i", "<C-a>", "<Home>")
vim.keymap.set("i", "<C-e>", "<End>")
vim.keymap.set("i", "<C-b>", "<Left>")
vim.keymap.set("i", "<C-f>", "<Right>")
vim.keymap.set("i", "<C-n>", "<Down>")
vim.keymap.set("i", "<C-p>", "<Up>")
vim.keymap.set("i", "<C-k>", "<C-o>D")
vim.keymap.set("i", "<M-b>", "<C-Left>")
vim.keymap.set("i", "<M-f>", "<C-Right>")
vim.keymap.set("i", "<M-m>", "<C-o>^")

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(event)
		local name = event.data.spec.name
		local kind = event.data.kind
		if name ~= "fff.nvim" or (kind ~= "install" and kind ~= "update") then
			return
		end
		if not event.data.active then
			vim.cmd.packadd("fff.nvim")
		end
		require("fff.download").download_or_build_binary()
	end,
	desc = "Install the fff native binary",
})

vim.pack.add({
	"https://github.com/folke/snacks.nvim",
	"https://github.com/roginfarrer/vim-dirvish-dovish",
	"https://github.com/justinmk/vim-dirvish",
	"https://codeberg.org/andyg/leap.nvim",
	"https://github.com/dmtrKovalenko/fff.nvim",
	"https://github.com/rebelot/kanagawa.nvim",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("*"),
	},
})

vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")

local leap = require("leap")
leap.opts.safe_labels = "tyuofghjklvbn"
leap.opts.labels = "sfnjklhowembuyvrgtqpcxz/SFNJKLHOWEIMBUYVRGTAQPCXZ"

vim.g.fff = {
	lazy_sync = false,
	prompt = "> ",
	debug = {
		enabled = false,
		show_scores = false,
	},
	hl = {
		border = "FFFBorder",
		title = "FFFTitle",
	},
	keymaps = {
		close = { "<Esc>", "<C-c>", "<C-g>" },
	},
}

local blink = require("blink.cmp")
local completion_enabled = true

blink.setup({
	enabled = function()
		return completion_enabled
	end,
	keymap = {
		preset = "super-tab",
		["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
		["<M-Tab>"] = { "show" },
		["<M-/>"] = {
			function(cmp)
				return cmp.show({ providers = { "buffer" } })
			end,
		},
		["<C-e>"] = {},
		["<C-g>"] = { "cancel", "fallback" },
		["<Tab>"] = {
			function(cmp)
				if cmp.snippet_active() then
					return cmp.accept()
				end
				return cmp.select_and_accept()
			end,
			"snippet_forward",
			"fallback",
		},
		["<S-Tab>"] = { "snippet_backward", "fallback" },
		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback_to_mappings" },
		["<C-n>"] = { "select_next", "fallback_to_mappings" },
		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },
		["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
	},
	completion = {
		list = {
			selection = {
				preselect = function()
					return not blink.snippet_active({ direction = 1 })
				end,
				auto_insert = true,
			},
		},
		trigger = {
			show_in_snippet = false,
			prefetch_on_insert = false,
		},
		menu = {
			auto_show = false,
			min_width = 1,
			border = "single",
			draw = {
				padding = 0,
				gap = 1,
				columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
			},
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 300,
			treesitter_highlighting = true,
			window = {
				min_width = 20,
				max_width = 72,
				max_height = 18,
				desired_min_width = 30,
				desired_min_height = 5,
				border = "rounded",
				scrollbar = true,
				winhighlight = "Normal:BlinkCmpDoc,FloatBorder:DiagnosticInfo,EndOfBuffer:BlinkCmpDoc",
			},
		},
		ghost_text = { enabled = false },
	},
	fuzzy = { implementation = "prefer_rust" },
	signature = { enabled = false },
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
		providers = {
			path = {
				opts = {
					get_cwd = function()
						return vim.fn.getcwd()
					end,
				},
			},
		},
	},
})

vim.keymap.set("n", "<leader>ta", function()
	completion_enabled = not completion_enabled
	if not completion_enabled then
		blink.hide()
		blink.hide_documentation()
		blink.hide_signature()
	end
	vim.notify("Auto completion " .. (completion_enabled and "enabled" or "disabled"))
end, { desc = "Toggle auto completion" })

vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
for _, server in ipairs(lsp_servers) do
	enable_lsp(server)
end

require("snacks").setup({
	bigfile = { enabled = true },
	quickfile = { enabled = true },
	indent = { enabled = false },
	notifier = { enabled = false },
	input = {
		win = {
			keys = {
				i_ctrl_g = { "<C-g>", "cancel", mode = { "i", "n" } },
			},
		},
	},
	picker = {
		enabled = true,
		actions = {
			explorer_paste = function(picker)
				local register = vim.v.register or "+"
				local files = vim.tbl_filter(function(file)
					return file ~= "" and vim.fn.filereadable(file) == 1
				end, vim.split(vim.fn.getreg(register) or "", "\n", { plain = true }))
				local dir = picker:dir()
				local name = #files == 1 and vim.fs.basename(files[1]) or nil

				if not name or not vim.uv.fs_stat(vim.fs.joinpath(dir, name)) then
					return require("snacks.explorer.actions").actions.explorer_paste(picker)
				end

				Snacks.input({ prompt = "Copy to", default = name }, function(value)
					if not value or value:match("^%s*$") then
						return
					end
					if value ~= vim.fs.basename(value) or value == "." or value == ".." then
						return Snacks.notify.warn("Enter a file name, not a path")
					end

					local to = vim.fs.joinpath(dir, value)
					if vim.uv.fs_stat(to) then
						return Snacks.notify.warn("File already exists:\n- `" .. to .. "`")
					end

					Snacks.picker.util.copy_path(files[1], to)
					local tree = require("snacks.explorer.tree")
					tree:refresh(dir)
					tree:open(dir)
					require("snacks.explorer.actions").update(picker, { target = to })
				end)
			end,
		},
		win = {
			input = {
				keys = {
					["<C-g>"] = { "close", mode = { "i", "n" } },
				},
			},
		},
	},
	explorer = { enabled = true, replace_netrw = false },
})

vim.keymap.set("n", "<C-n>", function()
	Snacks.picker.buffers()
end)
vim.keymap.set("n", "<C-p>", function()
	Snacks.picker.files()
end)
vim.keymap.set("n", "<M-s>l", function()
	Snacks.picker.lines()
end)
-- vim.keymap.set("n", "<leader>l", function()
-- 	Snacks.picker.grep()
-- end)
vim.keymap.set("n", "<leader>l", function()
	require("fff").live_grep()
end, { desc = "Live grep" })
-- vim.keymap.set("x", "<leader>l", function()
-- 	Snacks.picker.grep_word()
-- end)
vim.keymap.set("x", "<leader>l", function()
	require("fff").live_grep_under_cursor()
end, { desc = "Live grep selection" })
vim.keymap.set("n", "<leader>e", function()
	Snacks.explorer()
end)
vim.keymap.set("n", "<leader>d", function()
	Snacks.bufdelete()
end, { desc = "Delete buffer" })

vim.keymap.set("n", "<M-x>", ":")
vim.keymap.set("n", "cq", "<cmd>cclose<CR><cmd>lclose<CR>")
vim.keymap.set("n", "cn", "<cmd>cnext<CR>")
vim.keymap.set("n", "cp", "<cmd>cprevious<CR>")
vim.keymap.set("n", "co", function()
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			return vim.cmd.cclose()
		end
	end
	vim.cmd.copen()
end)

vim.cmd.colorscheme("kanagawa-dragon")
vim.api.nvim_set_hl(0, "FloatBorder", { link = "DiagnosticInfo" })
vim.api.nvim_set_hl(0, "FFFBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "FFFTitle", { link = "Title" })
