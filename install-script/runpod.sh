# Inside the pod run
mkdir -p /workspace/{.cache,.config,.local,tmp}

# Inside host
export HOST=ner
scp backup.sh $HOST:/workspace/tmp
scp ~/.gitconfig $HOST:/workspace/tmp
gpg --yes --output ~/.ssh/agung.b.sorlawan_id_ed25519.gpg \
  --encrypt --recipient tisorlawan@gmail.com ~/.ssh/agung.b.sorlawan_id_ed25519 &&
  scp ~/.ssh/agung.b.sorlawan_id_ed25519.gpg $HOST:/workspace/tmp &&
  rm ~/.ssh/agung.b.sorlawan_id_ed25519.gpg

# Inside the pod run
sudo apt update
sudo apt install locales git gnupg less ripgrep less
sudo sed -i 's/^# \(en_US.UTF-8 UTF-8\)$/\1/' /etc/locale.gen
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8

cd /workspace/tmp
cat >bashrc <<'EOF'
export HF_HOME=/workspace/.cache/huggingface
export TRANSFORMERS_CACHE=/workspace/.cache/huggingface/transformers
export HF_DATASETS_CACHE=/workspace/.cache/huggingface/datasets
export TORCH_HOME=/workspace/.cache/torch
export PIP_CACHE_DIR=/workspace/.cache/pip
export XDG_CACHE_HOME=/workspace/.cache
export XDG_CONFIG_HOME=/workspace/.config
export XDG_DATA_HOME=/workspace/.local/share

export NVIM_NOTTYFAST=1
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nvim
export VISUAL="$EDITOR"
export PAGER=less
export GIT_PAGER="$PAGER"
export LESS='-FRX'

export GPG_TTY=$(tty)

HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend checkwinsize

alias ls='ls --color=auto'
alias l='ls'
alias ll='ls -alF'
alias la='ls -A'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias g='git'
alias gs='git status --short --branch'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias df='df -h'
alias free='free -h'
alias a='source .venv/bin/activate'
alias p='python'

__git_prompt() {
  local branch
  branch=$(git branch --show-current 2>/dev/null) || return
  [[ -n $branch ]] || branch=$(git rev-parse --short HEAD 2>/dev/null) || return

  [[ -n $(git status --porcelain 2>/dev/null) ]] && branch+='*'
  printf ' (%s)' "$branch"
}

export LS_COLORS="${LS_COLORS}:ow=01;34:tw=01;34"
PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\[\e[1;33m\]$(__git_prompt)\[\e[0m\]\$ '

export PATH=$HOME/.local/share/bob/nvim-bin:$PATH
EOF

cat >tmux.conf <<'EOF'
set -sg escape-time 0
set -g default-terminal "screen-256color"
set -as terminal-features ",xterm-256color:RGB"

set-option -g default-shell /bin/bash
set-option -g default-command "/bin/bash"
EOF

## reconnect

curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh | bash
bob install v0.12.4
bob use v0.12.4

mkdir -p /workspace/.config/nvim
cat >/workspace/.config/nvim/init.lua <<'EOF'
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

# Inside pod

mkdir -p /root/.ssh
cd /workspace/tmp
cat >>ssh_config <<'EOF'
Host github.com
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/agung.b.sorlawan_id_ed25519
EOF
mkdir -p codex
mkdir -p cache
mv /root/.local .
rm /root/.bash_history
touch bash_history

# ----------------RESTART-----------------------

cd /workspace/tmp
./backup.sh
ln -srf .gitconfig /root/.gitconfig
ln -srf ./ssh_config /root/.ssh/config
gpg --yes --output /root/.ssh/agung.b.sorlawan_id_ed25519 --decrypt ./agung.b.sorlawan_id_ed25519.gpg && chmod 400 /root/.ssh/agung.b.sorlawan_id_ed25519
rm -rf ~/.codex
ln -srf codex ~/.codex
rm -rf ~/.cache
ln -srf cache ~/.cache
rm -rf ~/.local
ln -srf local ~/.local
ln -srf bashrc /root/.bashrc
ln -srf tmux.conf /root/.tmux.conf
ln -srf bash_history /root/.bash_history

## codex
sudo apt install bubblewrap
curl -fsSL https://chatgpt.com/codex/install.sh | sh
