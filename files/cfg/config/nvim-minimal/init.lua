vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.scrolloff = 4

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

vim.keymap.set({ "n", "i", "v", "o", "c", "t" }, "<C-x><C-s>", function()
	vim.cmd.write()
end, { desc = "Write buffer" })
vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "Write buffer" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("c", "<C-g>", "<C-c>")
vim.keymap.set("i", "<C-a>", "<Home>")
vim.keymap.set("i", "<C-e>", "<End>")
vim.keymap.set("i", "<C-b>", "<Left>")
vim.keymap.set("i", "<C-f>", "<Right>")
vim.keymap.set("i", "<C-n>", "<Down>")
vim.keymap.set("i", "<C-p>", "<Up>")
vim.keymap.set("i", "<C-k>", "<C-o>D")
vim.keymap.set("i", "<M-Tab>", "<C-x><C-n>")
vim.keymap.set("i", "<M-b>", "<C-Left>")
vim.keymap.set("i", "<M-f>", "<C-Right>")
vim.keymap.set("i", "<M-m>", "<C-o>^")

vim.pack.add({ "https://github.com/folke/snacks.nvim" })

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
	explorer = { enabled = true },
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
vim.keymap.set("n", "<leader>l", function()
	Snacks.picker.grep()
end)
vim.keymap.set("x", "<leader>l", function()
	Snacks.picker.grep_word()
end)
vim.keymap.set("n", "<leader>e", function()
	Snacks.explorer()
end)

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

vim.cmd([[colorscheme catppuccin]])
