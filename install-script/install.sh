#!/bin/bash

sudo apt install locales git
sudo sed -i 's/^# \(en_US.UTF-8 UTF-8\)$/\1/' /etc/locale.gen
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8

cat >~/.bashrc <<'EOF'
export NVIM_NOTTYFAST=1
export PATH="$HOME/.local/bin:$PATH"
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias grep='grep --color=auto'
EOF

cat >~/.tmux.conf <<'EOF'
set -sg escape-time 0
EOF

mkdir -p ~/.config/nvim
cat >~/.config/nvim/init.lua <<'EOF'
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

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.pack.add({ "https://github.com/folke/snacks.nvim" })

require("snacks").setup({
	bigfile = { enabled = true },
	quickfile = { enabled = true },
	indent = { enabled = false },
	notifier = { enabled = false },
	picker = {
		enabled = true,
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
EOF

#-----------RESTART-----------------------

# cat > install.sh << 'EOF'
#!/bin/bash

set -euo pipefail

NEOVIM_VERSION=0.12.4

if ! command -v tmux >/dev/null 2>&1; then
  sudo apt install tmux
fi

if ! command -v cmake >/dev/null 2>&1; then
  sudo apt install cmake
fi

wget -L "https://github.com/neovim/neovim/archive/refs/tags/v$NEOVIM_VERSION.tar.gz" -O "nvim-v$NEOVIM_VERSION.tar.gz"
rm -rf neovim-$NEOVIM_VERSION
tar xzf nvim-v$NEOVIM_VERSION.tar.gz
rm -rf nvim-v$NEOVIM_VERSION.tar.gz

cd neovim-$NEOVIM_VERSION
make CMAKE_BUILD_TYPE=Release -j
sudo make install
cd ..
sudo rm -rf neovim-$NEOVIM_VERSION

if ! command -v dust >/dev/null 2>&1; then
  curl -sSfL https://raw.githubusercontent.com/bootandy/dust/refs/heads/master/install.sh | sh
fi

if ! command -v fd >/dev/null 2>&1; then
  sudo apt install fd-find
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi
