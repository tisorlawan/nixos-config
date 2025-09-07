vim.g.mapleader = " "
vim.cmd.colorscheme("habamax")

------------------
---- @KEYMAPS ----
------------------
vim.keymap.set("n", "<leader>so", ":source %<cr>", { desc = "Source the current file", silent = true })
vim.keymap.set("n", "<leader>w", ":update<cr>", { desc = "Update file" })
vim.keymap.set("n", "<c-l>", "<c-w>l")
vim.keymap.set("n", "<c-h>", "<c-w>h")
vim.keymap.set("n", "<c-j>", "<c-w>j")
vim.keymap.set("n", "<c-k>", "<c-w>k")
vim.keymap.set("n", "<leader>fr", ":find **/*", { desc = "Find file recursively" })
vim.keymap.set("n", "<leader><tab>", "<C-^>", { desc = "Switch to alternative buffer", silent = true })
vim.keymap.set("n", "<C-x><C-n>", function()
	local current_file = vim.fn.expand("%")
	if current_file == "" then
		print("No file is currently open")
		return
	end

	local current_dir = vim.fn.fnamemodify(current_file, ":h")
	local current_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	-- Use vim.fn.input with completion instead of vim.ui.input
	local filename = vim.fn.input("Open: ", current_dir .. "/", "file")

	if filename and filename ~= "" then
		-- Check if file already exists
		if vim.fn.filereadable(filename) == 1 then
			-- File exists, just open it (don't copy content)
			vim.cmd("edit " .. vim.fn.fnameescape(filename))
		else
			-- File doesn't exist, create it with current buffer content
			vim.cmd("edit " .. vim.fn.fnameescape(filename))
			vim.api.nvim_buf_set_lines(0, 0, -1, false, current_content)
		end
	end
end, { desc = "Create new file with current buffer content or open existing file" })

------------------
---- @OPTIONS ----
------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"
vim.opt.wildignore = { "*.o", "*.a", "__pycache__", "*.pyc", "node_modules" }
vim.opt.breakindent = true
vim.opt.wrap = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { space = " ", trail = "•", tab = "» ", nbsp = "␣" }
vim.opt.scrolloff = 8
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.virtualedit = "block"

vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "#990000", fg = "#ffffff" })
local function show_trailing_whitespace()
	if vim.bo.filetype ~= "" and vim.bo.filetype ~= "help" then
		vim.fn.matchadd("TrailingWhitespace", "\\s\\+$")
	end
end
vim.api.nvim_create_autocmd({
	"BufWinEnter",
	"FileType",
	"InsertLeave",
}, {
	pattern = "*",
	callback = show_trailing_whitespace,
})
