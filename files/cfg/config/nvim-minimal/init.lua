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
-- Manual `:TrimWhitespace`, plus an opt-in auto-trim on save
-- (`:ToggleAutoTrimWhitespaceOnSave`, off by default).
local function trim_trailing_whitespace()
	local view = vim.fn.winsaveview()
	vim.cmd([[keeppatterns %s/\s\+$//e]])
	vim.fn.winrestview(view)
end
vim.api.nvim_create_user_command("TrimWhitespace", trim_trailing_whitespace, {
	desc = "Trim trailing whitespace",
})
local auto_trim_on_save = false
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("auto_trim_whitespace", { clear = true }),
	callback = function()
		if auto_trim_on_save then
			trim_trailing_whitespace()
		end
	end,
	desc = "Auto-trim trailing whitespace on save",
})
vim.api.nvim_create_user_command("ToggleAutoTrimWhitespaceOnSave", function()
	auto_trim_on_save = not auto_trim_on_save
	vim.notify("Auto-trim whitespace on save " .. (auto_trim_on_save and "on" or "off"))
end, {
	desc = "Toggle auto-trim of trailing whitespace on save",
})

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
		vim.hl.hl_op({ higroup = "IncSearch", timeout = 200 })
	end,
	desc = "Highlight yanked text",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "rust" },
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.tabstop = 4
	end,
	desc = "Use four-space indentation for C, C++, and Rust",
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
vim.api.nvim_create_autocmd("FileType", {
	pattern = "org",
	callback = function()
		vim.opt_local.conceallevel = 2
		vim.opt_local.concealcursor = "nc"
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.breakindent = true
		vim.opt_local.spell = false
		vim.opt_local.foldlevel = 99
		vim.opt_local.signcolumn = "no"
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.cursorline = true
		-- Zen hides the cmdline globally; org buffers always need one
		-- visible for `:` feedback.
		if vim.o.cmdheight == 0 then
			vim.o.cmdheight = 1
		end
		-- Emacs parity: M-RET adds a same-level heading at point,
		-- C-RET adds one after the whole subtree, both landing in insert.
		-- <Cmd> form so the Return keycode is consumed, not replayed as a
		-- plain newline after the action.
		vim.keymap.set(
			"i",
			"<M-CR>",
			'<Cmd>lua require("orgmode").action("org_mappings.meta_return")<CR>',
			{ buffer = true, desc = "Org meta return" }
		)
		vim.keymap.set(
			"i",
			"<M-RET>",
			'<Cmd>lua require("orgmode").action("org_mappings.meta_return")<CR>',
			{ buffer = true, desc = "Org meta return" }
		)
		vim.keymap.set(
			"i",
			"<C-CR>",
			'<Cmd>lua require("orgmode").action("org_mappings.insert_heading_respect_content")<CR>',
			{ buffer = true, desc = "Org insert heading after subtree" }
		)
		vim.keymap.set(
			"i",
			"<C-RET>",
			'<Cmd>lua require("orgmode").action("org_mappings.insert_heading_respect_content")<CR>',
			{ buffer = true, desc = "Org insert heading after subtree" }
		)
		-- Emacs parity while typing a headline: M-Left/M-Right
		-- promote/demote without leaving insert mode.
		vim.keymap.set(
			"i",
			"<M-Left>",
			'<Cmd>lua require("orgmode").action("org_mappings.do_promote")<CR>',
			{ buffer = true, desc = "Org promote headline" }
		)
		vim.keymap.set(
			"i",
			"<M-Right>",
			'<Cmd>lua require("orgmode").action("org_mappings.do_demote")<CR>',
			{ buffer = true, desc = "Org demote headline" }
		)
	end,
	desc = "Org reading-room display",
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
		name = "ts_ls",
		binary = "typescript-language-server",
		config = {
			cmd = { "typescript-language-server", "--stdio" },
			filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
			root_markers = {
				"package.json",
				"tsconfig.json",
				"jsconfig.json",
				".git",
			},
			init_options = {
				hostInfo = "neovim",
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

-- Pyright sends hover markdown with `&nbsp;` for indentation and `\_` for
-- escaped underscores. Both leak into the float as raw text, so clean the
-- markdown prose before Neovim renders it. Fenced code blocks are left alone.
local function clean_lsp_hover_markdown(lines)
	local in_fence = false
	for i, line in ipairs(lines) do
		if line:match("^%s*```") then
			in_fence = not in_fence
		elseif not in_fence then
			lines[i] = line:gsub("&nbsp;", " "):gsub("\\_", "_")
		end
	end
	return lines
end

-- Since 0.13, `vim.lsp.buf.hover` and signature help build their floats
-- directly through `vim.lsp.util.open_floating_preview` and never consult
-- `vim.lsp.handlers["textDocument/hover"]`, so patch the opener instead.
-- Diagnostics open their float as `plaintext` and are left untouched.
--
-- `enabled = false` keeps markdown files raw, but markdown floats read better
-- rendered: turn rendering on for the float buffer only, through the same
-- per-buffer path `:RenderMarkdown buf_enable` uses.
local open_floating_preview = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
	if type(contents) == "table" and syntax == "markdown" then
		clean_lsp_hover_markdown(contents)
	end
	local fbuf, fwin = open_floating_preview(contents, syntax, opts)
	if syntax == "markdown" and fbuf and vim.api.nvim_win_is_valid(fwin) then
		require("render-markdown.core.manager").set_buf(fbuf, true)
	end
	return fbuf, fwin
end

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

local diagnostics_enabled = true
local function sync_diagnostics(bufnr)
	vim.diagnostic.enable(diagnostics_enabled and not vim.bo[bufnr].modified, { bufnr = bufnr })
end
vim.keymap.set("n", "<leader>td", function()
	diagnostics_enabled = not diagnostics_enabled
	vim.diagnostic.enable(diagnostics_enabled)
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		sync_diagnostics(bufnr)
	end
	vim.notify("Diagnostics " .. (diagnostics_enabled and "on" or "off"))
end, { desc = "Toggle diagnostics" })
vim.api.nvim_create_autocmd({
	"BufReadPost",
	"BufWritePost",
	"DiagnosticChanged",
	"TextChanged",
	"TextChangedI",
	"TextChangedP",
}, {
	callback = function(event)
		sync_diagnostics(event.buf)
	end,
	desc = "Hide diagnostics while a buffer has unsaved changes",
})
-- `BufModifiedSet` was removed; `OptionSet` with pattern `modified` is its
-- replacement (deferred when triggered by `modified`).
vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "modified",
	callback = function(event)
		sync_diagnostics(event.buf)
	end,
	desc = "Hide diagnostics while a buffer has unsaved changes",
})

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

-- E363 "Pattern uses more memory than 'maxmempattern'" fires when regex
-- matching hits buffers with huge single lines, like the multi-megabyte
-- base64 dataset rows shown in the fff picker. The default cap is 1000 kB;
-- match memory is transient, so 20 MB is a safe ceiling.
vim.opt.maxmempattern = 20000

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.autoread = true
vim.opt.swapfile = false
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
vim.keymap.set("n", "<leader>pl", "<cmd>checkhealth vim.lsp<CR>", { desc = "LSP info" })

-- `SPC y p` yanks the buffer path relative to the cwd, `SPC y P` the absolute path.
local function yank_buffer_path(modifier)
	return function()
		local path = vim.fn.expand("%" .. modifier)
		if path == "" then
			vim.notify("Buffer has no file path", vim.log.levels.WARN)
			return
		end
		vim.fn.setreg("+", path)
		vim.notify("Yanked " .. path)
	end
end
vim.keymap.set("n", "<leader>yp", yank_buffer_path(":."), { desc = "Yank relative path" })
vim.keymap.set("n", "<leader>yP", yank_buffer_path(":p"), { desc = "Yank absolute path" })
vim.keymap.set("n", "gl", function()
	if not diagnostics_enabled or vim.bo.modified then
		return
	end
	vim.diagnostic.open_float({ scope = "line" })
end, { desc = "Show line diagnostics" })
-- @notes mirrors Emacs `C-x C-, n ...`: same files under `<leader>n ...`.
local notes_dir = vim.fn.expand("~/notes/")
local secrets_file = vim.fn.expand("~/.rice/secrets.org.gpg")
local credentials_file = vim.fn.expand("~/Documents/credentials/acc.txt")

local function edit_note(path)
	return function()
		vim.cmd.edit(vim.fn.fnameescape(vim.fn.expand(path)))
	end
end

vim.keymap.set("n", "<leader>na", edit_note(credentials_file), { desc = "Account credentials" })
vim.keymap.set("n", "<leader>nn", edit_note(notes_dir .. "TODO.org"), { desc = "TODO notes" })
vim.keymap.set("n", "<leader>nl", edit_note(notes_dir .. "til.org"), { desc = "TIL notes" })
vim.keymap.set("n", "<leader>nC", edit_note(notes_dir .. "COMMANDS.org"), { desc = "Commands notes" })
vim.keymap.set("n", "<leader>nc", edit_note(vim.fn.stdpath("config") .. "/init.lua"), { desc = "Neovim init.lua" })
vim.keymap.set("n", "<leader>ns", edit_note(secrets_file), { desc = "Secrets (gpg)" })

-- Transparent *.gpg read/write, the Emacs epa equivalent for the secrets file.
-- Plaintext never touches swap, backup, or undo files; gpg-agent pinentry
-- handles the passphrase on decrypt. Writes re-encrypt to the key ids already
-- on the file, so key rotation needs no config change; a write with no known
-- recipients aborts instead of touching disk.
local gnupg = vim.api.nvim_create_augroup("gnupg", { clear = true })
vim.api.nvim_create_autocmd("BufReadPre", {
	group = gnupg,
	pattern = "*.gpg",
	callback = function()
		vim.opt_local.swapfile = false
		vim.opt_local.backup = false
		vim.opt_local.writebackup = false
		vim.opt_local.undofile = false
		vim.opt_local.binary = true
	end,
	desc = "Stage *.gpg for transparent decrypt",
})
vim.api.nvim_create_autocmd("BufReadPost", {
	group = gnupg,
	pattern = "*.gpg",
	callback = function(args)
		local result = vim.system({ "gpg", "--decrypt", "--", args.file }, { text = true }):wait()
		if result.code ~= 0 then
			vim.bo[args.buf].binary = false
			vim.notify("gpg decrypt failed; showing ciphertext", vim.log.levels.ERROR)
			return
		end
		local plain = result.stdout or ""
		local lines = vim.split(plain, "\n", { plain = true })
		if lines[#lines] == "" then
			lines[#lines] = nil
		end
		if #lines == 0 then
			lines = { "" }
		end
		vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
		vim.bo[args.buf].binary = false
		vim.bo[args.buf].modified = false
		local ft = vim.filetype.match({ filename = args.file:gsub("%.gpg$", "") })
		if ft then
			vim.bo[args.buf].filetype = ft
		end
	end,
	desc = "Decrypt *.gpg after read",
})
local function gpg_recipients(path)
	local recipients = {}
	local packets = vim.fn.system({ "gpg", "--list-packets", "--", path })
	if vim.v.shell_error ~= 0 then
		return recipients
	end
	for keyid in packets:gmatch("keyid (%x+)") do
		table.insert(recipients, keyid)
	end
	return recipients
end
vim.api.nvim_create_autocmd("BufWriteCmd", {
	group = gnupg,
	pattern = "*.gpg",
	callback = function(args)
		local recipients = gpg_recipients(args.file)
		if #recipients == 0 then
			vim.notify("no gpg recipients for " .. args.file .. "; write aborted", vim.log.levels.ERROR)
			return
		end
		local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
		local argv = { "gpg", "--batch", "--yes", "--trust-model", "always", "--encrypt", "--output", args.file }
		for _, id in ipairs(recipients) do
			table.insert(argv, "--recipient")
			table.insert(argv, id)
		end
		table.insert(argv, "--")
		local result = vim.system(argv, { stdin = table.concat(lines, "\n") .. "\n", text = true }):wait()
		if result.code ~= 0 then
			vim.notify("gpg encrypt failed; write aborted", vim.log.levels.ERROR)
			return
		end
		vim.bo[args.buf].modified = false
	end,
	desc = "Encrypt buffer to *.gpg on write",
})

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<CR>", { desc = "Move left" })
vim.keymap.set("n", "<C-j>", "<cmd>wincmd j<CR>", { desc = "Move down" })
vim.keymap.set("n", "<C-k>", "<cmd>wincmd k<CR>", { desc = "Move up" })
local mc_ns = vim.api.nvim_create_namespace("nvim.multicursor")
vim.keymap.set("n", "<C-l>", function()
  if #vim.api.nvim_buf_get_extmarks(0, mc_ns, 0, -1, { limit = 1 }) > 0 then
    vim.api.nvim_buf_clear_namespace(0, mc_ns, 0, -1)
  else
    vim.cmd("wincmd l")
  end
end, { desc = "Clear multicursor or move right" })

vim.keymap.set("c", "<C-g>", "<C-c>")
vim.keymap.set("i", "<C-a>", "<Home>")
vim.keymap.set("i", "<C-e>", "<End>")
vim.keymap.set("i", "<C-b>", "<Left>")
vim.keymap.set("i", "<C-f>", "<Right>")
vim.keymap.set("i", "<C-n>", "<Down>")
vim.keymap.set("i", "<C-p>", "<Up>")
vim.keymap.set("i", "<C-k>", "<C-o>D")
-- Emacs `C-y`: yank the last kill in every mode, not only where `CTRL-R`
-- exists. The source is the clipboard register `+`; `clipboard=unnamedplus`
-- keeps it in sync with every yank and delete here, and it also picks up text
-- copied in another program, the way Emacs treats its kill ring. Replaces the
-- built-in `i_CTRL-Y` (insert char above) and `C-y` (scroll window up).
vim.keymap.set("i", "<C-y>", "<C-r>+", { desc = "Yank (paste register)" })
-- Normal mode has no `CTRL-R`. `P` inserts before the cursor, which is where
-- Emacs point sits: its block cursor covers the character after point. `P`
-- reads the same clipboard register.
vim.keymap.set("n", "<C-y>", "P", { desc = "Yank (paste register)" })
-- Visual mode yanks over the selection. The black-hole register keeps the
-- replaced text out of the unnamed register, so the kill survives.
vim.keymap.set("x", "<C-y>", '"_dP', { desc = "Yank (paste register)" })
-- `:` and `/` are readline prompts, where `CTRL-R CTRL-O` inserts the register
-- verbatim. blink.cmp's cmdline preset otherwise takes `C-y` for completion
-- accept; the `cmdline` keymap below drops that entry.
vim.keymap.set("c", "<C-y>", "<C-r><C-o>+", { desc = "Yank (paste register)" })
-- Terminals sit in terminal mode, where `CTRL-R` would be typed into the job
-- instead of pasting. `nvim_paste` goes through `vim.paste`, which routes to
-- the job for terminal buffers.
vim.keymap.set("t", "<C-y>", function()
	vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end, { desc = "Yank (paste register)" })
vim.keymap.set("i", "<M-b>", "<C-Left>")
vim.keymap.set("i", "<M-f>", "<C-Right>")
vim.keymap.set("i", "<M-m>", "<C-o>^")

-- render-markdown.nvim parses buffers with treesitter, so the markdown
-- grammars have to be present before it can draw anything. `cpp` is needed to
-- syntax-highlight C code blocks inside LSP hover floats; `c` ships with the
-- Neovim runtime already.
local treesitter_parsers = { "markdown", "markdown_inline", "cpp" }

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(event)
		local name = event.data.spec.name
		local kind = event.data.kind
		if kind ~= "install" and kind ~= "update" then
			return
		end
		if name == "fff.nvim" then
			if not event.data.active then
				vim.cmd.packadd("fff.nvim")
			end
			require("fff.download").download_or_build_binary()
		elseif name == "nvim-treesitter" then
			if not event.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			require("nvim-treesitter").install(treesitter_parsers)
		end
	end,
	desc = "Install native dependencies of installed plugins",
})

vim.pack.add({
	"https://github.com/folke/snacks.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	"https://github.com/SCJangra/table-nvim",
	"https://github.com/roginfarrer/vim-dirvish-dovish",
	"https://github.com/justinmk/vim-dirvish",
	"https://codeberg.org/andyg/leap.nvim",
	"https://github.com/dmtrKovalenko/fff.nvim",
	"https://github.com/nvim-orgmode/orgmode",
	"https://github.com/nvim-orgmode/org-bullets.nvim",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("*"),
	},
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/NeogitOrg/neogit",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/nvim-neo-tree/neo-tree.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/echasnovski/mini.icons",
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/aktersnurra/no-clown-fiesta.nvim",
	"https://github.com/folke/trouble.nvim",
	"https://github.com/hedyhli/outline.nvim",
})
-- One icon backend for both the snacks picker and neo-tree. `setup` defines the
-- `MiniIcons` global that snacks reads, and `mock_nvim_web_devicons` answers the
-- `require("nvim-web-devicons")` lookup neo-tree's icon provider makes.
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()
vim.cmd.packadd("orgmode")
vim.cmd.packadd("org-bullets.nvim")
require("orgmode").setup({
	org_agenda_files = vim.fn.expand("~/notes/**/*"),
	org_default_notes_file = vim.fn.expand("~/notes/refile.org"),
	org_hide_emphasis_markers = true,
	org_ellipsis = " ▾",
	org_blank_before_new_entry = { heading = false, plain_list_item = false },
	org_todo_keywords = { "TODO", "|", "DONE" },
	org_todo_keyword_faces = {
		TODO = ":foreground #b35300 :weight bold :slant italic",
		DONE = ":foreground #6f6d66 :weight normal",
	},
	mappings = {
		org = {
			-- Emacs parity: M-RET adds a same-level heading at point,
			-- C-RET adds one after the whole subtree.
			org_meta_return = { "<M-CR>", "<M-RET>" },
			org_insert_heading_respect_content = { "<C-CR>", "<C-RET>" },
			-- Emacs parity: M-Left/M-Right promote/demote the headline.
			-- Stock << / >> kept so existing muscle memory still works.
			org_do_promote = { "<<", "<M-Left>" },
			org_do_demote = { ">>", "<M-Right>" },
		},
	},
})
require("org-bullets").setup({
	concealcursor = true,
	symbols = {
		list = "•",
		headlines = { "◉", "○", "✸", "✿", "◆", "◇", "▶", "▷" },
		checkboxes = {
			half = { "◐", "@org.checkbox.halfchecked" },
			done = { "✓", "@org.keyword.done" },
			todo = { "○", "@org.keyword.todo" },
		},
	},
})

-- Magit-style git interface.
vim.cmd.packadd("neogit")
require("neogit").setup({ picker = "snacks" })
-- Gutter signs for added/changed/deleted lines, plus hunk navigation.
vim.cmd.packadd("gitsigns.nvim")
require("gitsigns").setup({
	current_line_blame = false,
	-- The stock hunk preview draws borderless and reads as part of the buffer
	-- underneath; match the diagnostic float instead. Deep-merged over the
	-- stock `{ style = 'minimal', relative = 'cursor', row = 0, col = 1 }`.
	preview_config = { border = "single" },
})
vim.keymap.set("n", "]h", function()
	require("gitsigns").nav_hunk("next", { target = "all" })
end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function()
	require("gitsigns").nav_hunk("prev", { target = "all" })
end, { desc = "Previous git hunk" })
-- Gitsigns' map wrapper seeds the function call on setup, so a plain
-- `require("gitsigns").preview_hunk` here would stay a no-op forever.
vim.keymap.set("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview git hunk" })
-- `K` focuses the open hunk preview (its window carries gitsigns' `hunk`
-- marker; `q` closes it). Otherwise the usual K: hover in LSP buffers,
-- `keywordprg` everywhere else, reached as the unmapped `normal! K`.
local function focus_hunk_preview()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.w[win].gitsigns_preview == "hunk" then
			vim.api.nvim_set_current_win(win)
			return true
		end
	end
	return false
end
local function hover()
	vim.lsp.buf.hover({
		border = "rounded",
		max_width = 72,
		max_height = 18,
		title = " Documentation ",
		title_pos = "center",
	})
end
vim.keymap.set("n", "K", function()
	if not focus_hunk_preview() then
		if vim.lsp.get_clients({ bufnr = 0 })[1] then
			hover()
		else
			vim.cmd("normal! K")
		end
	end
end, { desc = "Hover docs, or focus the hunk preview" })
-- Key-hint popup driven by the `desc` annotations on the mappings below.
vim.cmd.packadd("which-key.nvim")
require("which-key").setup({})

vim.keymap.set("n", "<leader>gg", function()
	require("neogit").open()
end, { desc = "Neogit" })

-- Markdown renders in place through treesitter, off until asked for so files
-- open raw. `SPC u u` matches the full nvim config, but stays buffer-local to
-- markdown instead of leading a global mapping. Tables opt out of that
-- rendering: they are aligned in the buffer text itself, so the file on disk
-- reads as a table too and nothing should be drawn over them.
require("nvim-treesitter").install(treesitter_parsers)
require("render-markdown").setup({
	enabled = false,
	pipe_table = { enabled = false },
	heading = { icons = {} },
})
-- The markdown grammar hides inline-code and emphasis markers with
-- `(#set! conceal "")`, and render-markdown turns conceal on for the buffer.
-- A concealed character still takes up its column in the source, so every pipe
-- placed by measuring the raw text drifts once rendering is on and an aligned
-- table stops lining up. Dropping that one rule for markdown_inline keeps the
-- markers on screen, which makes the rendered view match the source character
-- for character. Every other conceal rule is left alone.
do
	local query_file = vim.api.nvim_get_runtime_file("queries/markdown_inline/highlights.scm", false)[1]
	if query_file then
		local query = table.concat(vim.fn.readfile(query_file), "\n")
		local stripped = query:gsub(
			"%(%[%s*%(code_span_delimiter%)%s*%(emphasis_delimiter%)%s*%] @conceal%s*%(%#set! conceal \"\"%)%)",
			""
		)
		if stripped ~= query then
			vim.treesitter.query.set("markdown_inline", "highlights", stripped)
		end
	end
end
-- table-nvim aligns the table under the cursor when insert mode ends. It reads
-- the treesitter tree, and `vim.treesitter.get_node()` only consults trees that
-- are already parsed, so the grammar is started here and re-parsed just before
-- the plugin looks. This autocmd is registered ahead of the plugin's own, and
-- autocmds run in creation order, so the tree is fresh by the time it fires.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(event)
		vim.treesitter.start(event.buf)
	end,
	desc = "Start treesitter for markdown",
})
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*.md",
	callback = function(event)
		vim.treesitter.get_parser(event.buf):parse()
	end,
	desc = "Refresh the treesitter tree before table-nvim aligns",
})
require("table-nvim").setup({ mappings = false })
-- `SPC m r` aligns every table in the buffer. Tables are found through the
-- grammar, where a pipe table inside a fenced block is not a `pipe_table` node,
-- so code samples are left alone. Ranges are collected up front and the tree is
-- re-parsed between tables because each render invalidates it.
local function realign_markdown_tables()
	local buf = vim.api.nvim_get_current_buf()
	local parser = vim.treesitter.get_parser(buf)
	local query = vim.treesitter.query.parse("markdown", "(pipe_table) @table")
	local ranges = {}
	for _, node in query:iter_captures(parser:parse()[1]:root(), buf) do
		ranges[#ranges + 1] = { node:range() }
	end
	local md_table = require("table-nvim.md_table")
	for i = #ranges, 1, -1 do
		local root = require("table-nvim.utils").get_tbl_root(vim.treesitter.get_node({
			bufnr = buf,
			pos = { ranges[i][1], ranges[i][2] },
		}))
		if root then
			md_table:new(root):render()
			parser:parse()
		end
	end
end
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(event)
		vim.keymap.set("n", "<leader>uu", "<cmd>RenderMarkdown toggle<cr>", {
			buffer = event.buf,
			desc = "Toggle markdown rendering",
		})
		vim.keymap.set("n", "<leader>mr", realign_markdown_tables, {
			buffer = event.buf,
			desc = "Align all tables in the buffer",
		})
	end,
	desc = "Set up markdown buffers",
})

vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")

-- Auto-close brackets and quotes. lisp/scheme stay off so paredit-style
-- editing does not fight the pairs.
vim.cmd.packadd("nvim-autopairs")
require("nvim-autopairs").setup({
	disable_filetype = { "TelescopePrompt", "spectre_panel", "lisp", "scheme" },
})

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
		-- fff pins `CursorLine` on the preview's match line (location_utils.lua
		-- sets `line_hl_group`, at any priority), and Neovim paints a line
		-- highlight's background over the backgrounds of cell highlights on
		-- that line. The match therefore keeps only the IncSearch foreground
		-- over the band, which leaves dark ink on a dark band, 1.1:1. Keep the
		-- band and give the matched text the accent the theme already pairs
		-- with it: `FFFPreviewMatch` below copies CursorLineNr, the colour of
		-- the line number that marks the same match line.
		winhl = {
			preview = "Normal:NormalFloat,FloatBorder:FloatBorder,FloatTitle:Title,IncSearch:FFFPreviewMatch",
		},
	},
	keymaps = {
		close = { "<Esc>", "<C-c>", "<C-g>" },
		-- `<C-q>` types q in fff's insert-mode prompt; send results
		-- straight to snacks instead.
		send_to_quickfix = { "<C-l>", "<C-q>" },
	},
}

local blink = require("blink.cmp")
local completion_manual = false

blink.setup({
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
		-- `C-y` is Emacs yank (see the key maps above); drop it from the
		-- presets so neither insert mode nor the cmdline preset can take it.
		["<C-y>"] = {},
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
	cmdline = {
		keymap = {
			-- The cmdline preset maps `C-y` to `select_and_accept`, which
			-- shadows the Emacs yank mapped above for `:` and `/`.
			["<C-y>"] = {},
		},
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
			auto_show = function()
				return not completion_manual
			end,
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
		min_keyword_length = 3,
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
	completion_manual = not completion_manual
	if completion_manual then
		blink.hide()
		blink.hide_documentation()
		blink.hide_signature()
	end
	vim.notify("Completion menu " .. (completion_manual and "manual" or "auto"))
end, { desc = "Toggle completion menu auto-show" })

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
		-- `SPC f f` lists tracked, untracked, hidden, and `.gitignore`d files.
		-- `.git` stays out through the finder's own default arguments. The three
		-- excluded entries are dependency and bytecode trees whose contents are
		-- noise in a file list. `fd`'s `-E` matches a file or directory name
		-- anywhere in the tree, so a nested `node_modules` is dropped too.
		sources = {
			files = {
				hidden = true,
				ignored = true,
				exclude = { ".agent-shell", ".cache", ".venv", "node_modules", "__pycache__", ".pytest_cache", ".mypy_cache", ".ruff_cache", "build/lib", "venv" },
			},
		},
		win = {
			input = {
				keys = {
					["<C-g>"] = { "close", mode = { "i", "n" } },
					-- Close on a single Esc from the prompt, like `<C-c>`.
					["<Esc>"] = { "cancel", mode = "i" },
				},
			},
		},
	},
})
require("trouble").setup()
require("outline").setup()
vim.keymap.set("n", "<leader>oo", "<cmd>Outline<CR>", { desc = "Toggle outline" })
vim.keymap.set("n", "<leader>xx", function()
	require("trouble").open({ buf = 0, mode = "diagnostics" })
end, { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<C-n>", function()
	Snacks.picker.buffers()
end)
vim.keymap.set("n", "<C-p>", function()
	require("fff").find_files()
end, { desc = "Pick files" })
vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.files()
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fl", function()
	Snacks.picker.lines()
end, { desc = "Lines in buffer" })
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
-- fff -> snacks: C-l in the fff prompt sends the current result set (or
-- Tab selection) to the snacks quickfix picker directly.
vim.keymap.set("n", "<leader>q", function()
	Snacks.picker.qflist()
end, { desc = "Quickfix in snacks" })
-- Route fff's C-l past the stock quickfix window into snacks.
do
	local utils = require("fff.picker_ui.utils")
	local orig_send = utils.send_to_quickfix
	utils.send_to_quickfix = function()
		orig_send()
		vim.schedule(function()
			vim.cmd("cclose")
			Snacks.picker.qflist()
		end)
	end
	require("fff.picker_ui.picker_ui").send_to_quickfix = utils.send_to_quickfix
end
-- File tree in a left sidebar. `hijack_netrw_behavior = "disabled"` leaves
-- directory buffers to vim-dirvish; neo-tree only draws its own sidebar.
vim.cmd.packadd("neo-tree.nvim")
vim.keymap.set("n", "<leader>e", "<cmd>Neotree source=filesystem reveal=true position=left toggle<cr>", {
	desc = "Toggle file tree",
})

-- `Y` offers the node's path in the forms that get pasted into a command or an
-- import. neo-tree has no default mapping here; `y` marks nodes for a later
-- move or copy, which is a different operation.
local function copy_path(state)
	local node = state.tree:get_node()
	local filepath = node:get_id()
	local filename = node.name
	local modify = vim.fn.fnamemodify
	local options = {
		{ label = "Absolute path", value = filepath },
		{ label = "Path relative to CWD", value = modify(filepath, ":.") },
		{ label = "Path relative to HOME", value = modify(filepath, ":~") },
		{ label = "Filename", value = filename },
		{ label = "Filename without extension", value = modify(filename, ":r") },
		{ label = "Extension", value = modify(filename, ":e") },
	}

	vim.ui.select(options, {
		prompt = "Choose to copy to clipboard:",
		format_item = function(item)
			return string.format("%s: %s", item.label, item.value)
		end,
	}, function(choice)
		if choice then
			vim.fn.setreg("+", choice.value)
			vim.notify("Copied: " .. choice.value)
		end
	end)
end

local function refresh_filesystem(state)
	require("neo-tree.sources.filesystem")._navigate_internal(state, nil, nil, nil, false)
end

-- `hide_gitignored` lives in the state, not the config, because the toggle is
-- per-window. Re-navigating is what re-runs the scan with the new filter.
local function toggle_gitignored(state)
	state.filtered_items.hide_gitignored = not state.filtered_items.hide_gitignored
	vim.notify(
		"Toggling gitignored files: " .. tostring(not state.filtered_items.hide_gitignored),
		vim.log.levels.INFO,
		{ title = "Neo-tree" }
	)
	refresh_filesystem(state)
end

-- Open with a CWD-relative path when the file is under the CWD, so the buffer
-- name stays short and `:e` completions keep working. Reuses the window holding
-- the file when one exists, and skips neo-tree's own window when picking the
-- window to edit in.
local function open_with_relative_path(state)
	local node = state.tree:get_node()
	if node.type == "directory" then
		require("neo-tree.sources.filesystem.commands").toggle_node(state)
		return
	end
	if node.type ~= "file" then
		return
	end

	local abs_path = node:get_id()
	local target_buf = vim.fn.bufnr(abs_path)
	if target_buf ~= -1 then
		local win = vim.fn.bufwinid(target_buf)
		if win ~= -1 then
			vim.api.nvim_set_current_win(win)
			return
		end
	end

	local path = abs_path
	local relative = vim.fn.fnamemodify(abs_path, ":.")
	if not relative:match("^%.%.") then
		path = relative
	end

	local real_wins = vim.tbl_filter(function(win)
		local buf = vim.api.nvim_win_get_buf(win)
		local buftype = vim.bo[buf].buftype
		local filetype = vim.bo[buf].filetype
		return buftype ~= "nofile" and buftype ~= "prompt" and filetype ~= "neo-tree"
	end, vim.api.nvim_list_wins())

	if #real_wins == 0 then
		vim.cmd.vsplit()
	else
		vim.api.nvim_set_current_win(real_wins[1])
	end

	vim.cmd("edit " .. vim.fn.fnameescape(path))
end

require("neo-tree").setup({
	close_if_last_window = true,
	enable_git_status = true,
	window = {
		position = "left",
		mappings = {
			I = toggle_gitignored,
			Y = copy_path,
			["<cr>"] = open_with_relative_path,
			o = open_with_relative_path,
			["<2-LeftMouse>"] = open_with_relative_path,
		},
	},
	filesystem = {
		follow_current_file = { enabled = false },
		use_libuv_file_watcher = true,
		hijack_netrw_behavior = "disabled",
		-- The tree hides dotfiles until `H`; keep the ignore file itself
		-- visible so the reason a sibling is filtered away stays on screen.
		filtered_items = { always_show = { ".gitignore" } },
	},
})

vim.keymap.set("n", "<leader>d", function()
	Snacks.bufdelete()
end, { desc = "Delete buffer" })
-- Undo tree browser; undo history itself persists across sessions via
-- `undofile`, so branches survive a restart too.
vim.keymap.set("n", "<leader>U", function()
	Snacks.picker.undo()
end, { desc = "Undo tree" })
local zen_off = nil
local function toggle_zen()
	local on = zen_off == nil
	if on then
		zen_off = {
			laststatus = vim.o.laststatus,
			cmdheight = vim.o.cmdheight,
			showtabline = vim.o.showtabline,
			winbar = vim.o.winbar,
		}
		vim.o.laststatus = 0
		vim.o.cmdheight = 0
		vim.o.showtabline = 0
		vim.o.winbar = ""
	else
		vim.o.laststatus = zen_off.laststatus
		vim.o.cmdheight = zen_off.cmdheight
		vim.o.showtabline = zen_off.showtabline
		vim.o.winbar = zen_off.winbar
		zen_off = nil
	end
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		-- Terminal buffers never take line numbers, zen or not.
		local is_term = vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal"
		vim.wo[win].number = not on and not is_term
		vim.wo[win].relativenumber = not on and not is_term
		vim.wo[win].signcolumn = on and "no" or "yes"
		vim.wo[win].statuscolumn = ""
	end
end
vim.keymap.set("n", "<leader>zz", toggle_zen, { desc = "Toggle zen mode" })

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

-- `SPC t t` flips this; `apply_color_mode` re-applies the scheme so kanagawa's
-- `overrides` closure (light) and no-clown-fiesta's `transparent` option (dark)
-- pick the opaque Normal up (or drop it).
-- Starts transparent; kanagawa's `transparent = true` keeps Normal bg NONE
-- and `opaque_bg` only re-adds it when toggled on.
local opaque_bg = false
vim.cmd.packadd("kanagawa.nvim")
vim.cmd.packadd("no-clown-fiesta.nvim")
vim.pack.add({
  {
    src = 'https://github.com/oxidescheme/nvim',
    name = 'oxide',
  },
})

require("kanagawa").setup({
	transparent = true,
	colors = {
		theme = {
			wave = {
				syn = {
					-- Comments in kanagawa's own springGreen instead of the default
					-- faint gray-green (#727169), so they read as a distinct voice
					-- against the dark background rather than faded code.
					-- comment = "#98bb6c", -- italic
				},
			},
			lotus = {
				ui = {
					-- High-contrast light mode: lotus's default ink (#545464) is a soft
					-- blue-gray and its surfaces carry a warm cream tint. Push text to
					-- near-black and flatten the surface ramp to neutral grays on white.
					fg = "#1f1f24",
					fg_dim = "#4b4b52",
					bg = "#ffffff",
					bg_dim = "#f5f5f5",
					bg_gutter = "#ffffff",
					bg_m1 = "#f2f2f2",
					bg_m2 = "#eaeaea",
					bg_m3 = "#d4d4d4", -- also WinSeparator fg: needs a faint visible line on white
					bg_p1 = "#ececec",
					bg_p2 = "#e0e0e0",
					nontext = "#74726c", -- line numbers
					float = { bg = "#f2f2f2" },
					bg_visual = "#e4e4e4",
					bg_search = "#dcdcdc",
					pmenu = {
						bg = "#f0f0f0",
						bg_sel = "#d9d9d9",
						bg_sbar = "#f0f0f0",
						bg_thumb = "#d9d9d9",
					},
				},
				syn = {
					-- Full monochrome: hues are gone, hierarchy comes from tone plus
					-- kanagawa's baked-in styles (statement bold, keyword and comment
					-- italic, boolean bold).
					string = "#5a5a60",
					number = "#3d3d44",
					constant = "#3d3d44", -- booleans (bold)
					parameter = "#3d3d44",
					fun = "#1f1f24",
					statement = "#111114",
					keyword = "#111114", -- italic
					operator = "#4b4b52",
					preproc = "#3d3d44",
					type = "#45454c",
					regex = "#4b4b52",
					deprecated = "#8c8c90",
					comment = "#6f6d66", -- italic
					punct = "#4b4b52",
					special1 = "#4b4b52",
					special2 = "#5a5a60",
					special3 = "#5a5a60",
				},
			},
		},
	},
	overrides = function(colors)
		local overrides = {
			NormalFloat = { bg = "NONE" },
			FloatTitle = { bg = "NONE" },
			WinBar = { bg = "NONE" },
			WinBarNC = { bg = "NONE" },
			StatusLine = { bg = "NONE" },
			StatusLineNC = { bg = "NONE" },
			StatusLineTerm = { bg = "NONE" },
			StatusLineTermNC = { bg = "NONE" },
		}
		if vim.o.background == "light" then
			-- Kanagawa paints the cursor line number diagnostic-orange; in the
			-- monochrome light scheme it is plain black bold like other emphasis.
			overrides.CursorLineNr = { fg = "#111114", bg = "#ffffff", bold = true }
		end
		if opaque_bg then
			overrides.Normal = { bg = colors.theme.ui.bg }
		end
		return overrides
	end,
})
local function get_color_mode()
	local raw = vim.env.COLOR or vim.env.LC_COLOR

	if not raw or raw == "" then
		local color_file = io.open(vim.fn.expand("~/.color"), "r")
		if color_file then
			raw = (color_file:read("*a") or "")
			color_file:close()
		end
	end
	raw = vim.trim(raw or "")
	return raw:find("light") and "light" or "dark"
end

local function apply_org_highlights()
	if vim.o.background == "light" then
		local levels = { "#111114", "#2b2b31", "#45454c", "#5a5a60", "#6f6d66", "#8c8c90" }
		for i, fg in ipairs(levels) do
			vim.api.nvim_set_hl(0, "@org.headline.level" .. i, { fg = fg, bold = i <= 2 })
		end
		vim.api.nvim_set_hl(0, "@org.headline.level7", { link = "@org.headline.level5" })
		vim.api.nvim_set_hl(0, "@org.headline.level8", { link = "@org.headline.level6" })
		vim.api.nvim_set_hl(0, "@org.checkbox", { fg = "#6f6d66" })
		vim.api.nvim_set_hl(0, "@org.checkbox.halfchecked", { fg = "#b35300", bold = true })
		vim.api.nvim_set_hl(0, "@org.keyword.todo", { fg = "#b35300", bold = true, italic = true })
		vim.api.nvim_set_hl(0, "@org.keyword.done", { fg = "#6f6d66", italic = true })
		vim.api.nvim_set_hl(0, "@org.timestamp.active", { fg = "#4b4b52", underline = true })
		vim.api.nvim_set_hl(0, "@org.timestamp.inactive", { fg = "#6f6d66", italic = true })
		vim.api.nvim_set_hl(0, "@org.tag", { fg = "#8c8c90", italic = true })
		vim.api.nvim_set_hl(0, "@org.plan", { fg = "#4b4b52", italic = true })
		vim.api.nvim_set_hl(0, "@org.drawer", { fg = "#8c8c90", italic = true })
		vim.api.nvim_set_hl(0, "@org.properties", { fg = "#8c8c90", italic = true })
		vim.api.nvim_set_hl(0, "@org.block", { fg = "#4b4b52" })
	else
		vim.api.nvim_set_hl(0, "@org.keyword.todo", { fg = "#e8a06a", bold = true })
		vim.api.nvim_set_hl(0, "@org.keyword.done", { fg = "#7a7a85", italic = true })
		vim.api.nvim_set_hl(0, "@org.checkbox.halfchecked", { fg = "#e8a06a", bold = true })
	end
end
local function apply_color_mode()
	-- Kanagawa and no-clown-fiesta paint StatusLine with a solid bg; clear it
	-- on every colorscheme load so the statusline stays transparent.
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("transparent_statusline", { clear = true }),
		callback = function()
			for _, group in ipairs({ "StatusLine", "StatusLineNC", "StatusLineTerm", "StatusLineTermNC" }) do
				local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
				hl.bg = "NONE"
				hl.ctermbg = "NONE"
				vim.api.nvim_set_hl(0, group, hl)
			end
		end,
		desc = "Keep statusline background transparent",
	})
	vim.o.background = get_color_mode()
	if vim.o.background == "light" then
		vim.cmd.colorscheme("kanagawa-lotus")
	else
		-- The plugin's colors file calls `load()` with no opts, which resets
		-- its settings to defaults — a prior `setup({ transparent = ... })`
		-- would be discarded. Load directly to pass `transparent` through for
		-- the `SPC t t` toggle, then fire the ColorScheme autocmds that
		-- `:colorscheme` would have run.
		-- require("no-clown-fiesta").load({ theme = "dark", transparent = not opaque_bg })
		-- vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "no-clown-fiesta" })
		vim.cmd.colorscheme("kanagawa-wave")
    -- vim.cmd.colorscheme("oxide")
	end
	-- :colorscheme wipes user highlight links, so (re)apply them here, after
	-- the theme, rather than once at startup.
	if vim.o.background == "light" then
		-- Monochrome light: gray borders instead of DiagnosticInfo blue.
		vim.api.nvim_set_hl(0, "FloatBorder", { link = "Comment" })
		-- kanagawa-lotus pairs IncSearch's reversed ink (#dcd7ba, lotusGray)
		-- with the warning orange (#e98a00). Both are light, about 1.8:1, so
		-- every match reads as a washed-out block: `/`, `:s///c`, and fff's
		-- match highlight all use this group. Keep the scheme's background and
		-- put the light scheme's ink on it.
		local incsearch = vim.api.nvim_get_hl(0, { name = "IncSearch", link = false })
		vim.api.nvim_set_hl(0, "IncSearch", { fg = "#1f1f24", bg = incsearch.bg })
	else
		vim.api.nvim_set_hl(0, "FloatBorder", { link = "DiagnosticInfo" })
	end
	vim.api.nvim_set_hl(0, "FFFBorder", { link = "FloatBorder" })
	vim.api.nvim_set_hl(0, "FFFTitle", { link = "Title" })
	-- Target of the preview `winhl` above. CursorLineNr is the theme's accent
	-- for text sitting on `CursorLine`'s background, which is the band fff
	-- pins on the preview's match line, so it is legible there by design. Bold
	-- keeps the match distinct now that the band, not the match, owns the
	-- background. `link = false` resolves the chain: a linked group reports no
	-- foreground of its own.
	local line_accent = vim.api.nvim_get_hl(0, { name = "CursorLineNr", link = false }).fg
	vim.api.nvim_set_hl(0, "FFFPreviewMatch", { fg = line_accent, bold = true })
	apply_org_highlights()
 end

apply_color_mode()
vim.keymap.set("n", "<leader>tt", function()
	opaque_bg = not opaque_bg
	apply_color_mode()
end, { desc = "Toggle background transparency" })
vim.keymap.set("n", "<leader>tw", function()
	vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle line wrap" })

-- Re-apply the colorscheme when ~/.color changes (see ~/.scripts/set-color).
-- One persistent handle: a write can queue several inotify events, so apply
-- is debounced instead of re-arming a new watcher per event.
do
	local color_path = vim.fn.expand("~/.color")
	local pending = false

	local function apply_debounced()
		if pending then
			return
		end
		pending = true
		vim.defer_fn(function()
			pending = false
			apply_color_mode()
		end, 100)
	end

	local handle = vim.uv.new_fs_event()
	handle:start(color_path, {}, vim.schedule_wrap(apply_debounced))
end

-- Fish as the `:terminal` shell, plus the buffer options a terminal buffer
-- wants. Tabs, splits, and tab switching belong to the terminal emulator.
local fish = vim.fn.exepath("fish")
if fish ~= "" then
	vim.o.shell = fish
	vim.env.SHELL = fish
end

local term_group = vim.api.nvim_create_augroup("term_buffers", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
	group = term_group,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.opt_local.cursorline = false
		vim.opt_local.list = false
		vim.opt_local.scrolloff = 0
		vim.opt_local.sidescrolloff = 0
		vim.bo.bufhidden = "hide"
	end,
})
-- Terminals land in insert mode on entry; `<C-g>` below leaves it.
vim.api.nvim_create_autocmd("BufEnter", {
	group = term_group,
	callback = function()
		if vim.bo.buftype == "terminal" then
			pcall(vim.cmd.startinsert)
		end
	end,
})

local function term_job_alive(buf)
	local job = vim.b[buf].terminal_job_id
	return job ~= nil and vim.fn.jobwait({ job }, 0)[1] == -1
end

-- `<Esc>` passes through to the job (fish, fzf, nested vim need it);
-- `<C-g>` (Emacs cancel, matches `c <C-g>`) exits to normal mode.
-- The stock `<C-\><C-n>` still works too.
vim.keymap.set("t", "<C-g>", [[<C-\><C-n>]], { desc = "Terminal normal mode" })

-- Fish history on `M-p`/`M-n`, Emacs ghostel parity (`up`/`down`).
vim.keymap.set("t", "<M-p>", "<Up>", { desc = "Fish history previous" })
vim.keymap.set("t", "<M-n>", "<Down>", { desc = "Fish history next" })

local function live_term(buf)
	return buf ~= nil
		and vim.api.nvim_buf_is_valid(buf)
		and vim.bo[buf].buftype == "terminal"
		and term_job_alive(buf)
end

-- Quit guard: warn before the session exits while terminal jobs run. Native
-- `:q`/`:qa` (and `ZQ`, which is `:q!`) exit silently with live jobs; only
-- the `:wqa`/`:xa` family refuses with E948. Closing one window never
-- prompts: hidden terminal buffers keep their jobs.
local function live_terms()
	local terms = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if live_term(buf) then
			terms[#terms + 1] = buf
		end
	end
	return terms
end

local function confirm_session_exit(action)
	local terms = live_terms()
	if #terms == 0 then
		return true
	end
	local noun = #terms == 1 and "1 terminal job" or #terms .. " terminal jobs"
	return vim.fn.confirm(noun .. " still running. " .. action .. " anyway?", "&Yes\n&No", 2) == 1
end

local function last_window()
	return vim.fn.winnr("$") == 1 and vim.fn.tabpagenr("$") == 1
end

-- `exits` marks the `:qa` family, which always ends the session; other
-- spellings only do so from the last window of the last tab.
local function guarded_quit(cmd, exits)
	if (exits or last_window()) and not confirm_session_exit(cmd) then
		return
	end
	vim.cmd(cmd)
end

vim.keymap.set("n", "ZZ", function()
	guarded_quit("x", false)
end, { desc = "Write and quit (warns on live terminals)" })
vim.keymap.set("n", "ZQ", function()
	guarded_quit("q!", false)
end, { desc = "Quit without saving (warns on live terminals)" })

-- Typed quit spellings, bang included; ranges/counts fall through to native.
local quit_words = {
	q = "q",
	qu = "q",
	qui = "q",
	quit = "q",
	qa = "qa",
	qal = "qa",
	qall = "qa",
	wq = "wq",
	wqa = "wqa",
	wqal = "wqa",
	wqall = "wqa",
	x = "x",
	xa = "xa",
	xal = "xa",
	xall = "xa",
}
vim.keymap.set("c", "<CR>", function()
	if vim.fn.getcmdtype() ~= ":" then
		return "<CR>"
	end
	local word, bang, rest = vim.fn.getcmdline():match("^%s*(%a+)(!?)(.-)%s*$")
	local base = word and quit_words[word] or nil
	-- Only `:wq` takes a trailing file.
	if base == nil or (base ~= "wq" and rest ~= "") then
		return "<CR>"
	end
	if base ~= "qa" and base ~= "wqa" and base ~= "xa" and not last_window() then
		return "<CR>"
	end
	if confirm_session_exit(base .. (bang == "!" and "!" or "")) then
		return "<CR>"
	end
	-- `<C-c>` abandons the cmdline (`<Esc>` does not take here).
	return "<C-c>"
end, { expr = true, desc = "Quit guard for live terminals" })


-- Terminal `C-p`/`C-n` match the normal-mode file/buffer pickers; the
-- `<C-\><C-n>` prefix exits terminal mode before the picker opens.
vim.keymap.set("t", "<C-p>", [[<C-\><C-n><Cmd>lua require("fff").find_files()<CR>]], { desc = "Pick files" })
vim.keymap.set("t", "<C-n>", [[<C-\><C-n><Cmd>lua Snacks.picker.buffers()<CR>]], { desc = "Pick buffers" })
