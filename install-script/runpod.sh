#!/usr/bin/env bash
# Usage: ./runpod.sh push    (on host)
#        ./runpod.sh setup   (inside the pod)
set -euo pipefail

push() {
  export HOST=jev
  export TMP=/workspace/tmp
  ssh "$HOST" "mkdir -p /workspace/.cache /workspace/.config/nvim /workspace/.local $TMP"
  gpg --yes --output - \
    --encrypt --recipient tisorlawan@gmail.com \
    ~/.ssh/agung.b.sorlawan_id_ed25519 |
    ssh "$HOST" "cat > $TMP/agung.b.sorlawan_id_ed25519.gpg"
  scp backup.sh "$(readlink -f "${BASH_SOURCE[0]}")" "$HOST:$TMP/"
  scp ~/.gitconfig "$HOST:$TMP/.gitconfig"
  scp files/cfg/config/nvim-minimal/init.lua "$HOST:/workspace/.config/nvim/init.lua"
}

setup() {
  export TMP=/workspace/tmp
  sudo apt update
  sudo apt install -y locales git gnupg less ripgrep bubblewrap fd-find
  sudo ln -sf "$(which fdfind)" /usr/bin/fd
  sudo sed -i 's/^# \(en_US.UTF-8 UTF-8\)$/\1/' /etc/locale.gen
  sudo locale-gen en_US.UTF-8
  sudo update-locale LANG=en_US.UTF-8
  find . -type d | xargs -I {} chmod 755 {}
  find . -type f | xargs -I {} chmod 644 {}
  chmod +x runpod.sh
  chmod +x backup.sh

  mkdir -p "$TMP" /root/.ssh
  cd "$TMP"

  cat >bashrc <<'EOF'
export HF_HOME=/workspace/.cache/huggingface
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

  cat >ssh_config <<'EOF'
Host github.com
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/agung.b.sorlawan_id_ed25519
EOF

  # Persistent state dirs on /workspace
  if [ -d /root/.local ] && [ ! -L /root/.local ]; then
    mv /root/.local local
  fi
  mkdir -p codex cache local
  touch bash_history

  # Link everything into $HOME
  ln -srf bashrc /root/.bashrc
  ln -srf tmux.conf /root/.tmux.conf
  ln -srf bash_history /root/.bash_history
  ln -srf .gitconfig /root/.gitconfig
  rm -f /root/.ssh/config
  ln -srf "$TMP/ssh_config" /root/.ssh/config
  chmod 400 /root/.ssh/config
  rm -rf /root/.cache
  ln -srf cache /root/.cache
  rm -rf /root/.local
  ln -srf local /root/.local
  source /root/.bashrc

  # Tools
  rm -rf ~/.local/share/bob/
  curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh | bash
  ~/.local/bin/bob install v0.12.4
  ~/.local/bin/bob use v0.12.4

  # CODEX_NON_INTERACTIVE=1 curl -fsSL https://chatgpt.com/codex/install.sh | sh
  # if [ -d ~/.codex ] && [ ! -L ~/.codex ]; then
  #   cp -a --no-preserve=ownership ~/.codex/. codex/
  #   rm -rf ~/.codex
  # fi
  # ln -srf codex ~/.codex

  # Restore git config history and SSH key
  ./backup.sh
  gpg --yes --output /root/.ssh/agung.b.sorlawan_id_ed25519 \
    --decrypt agung.b.sorlawan_id_ed25519.gpg
  chmod 400 /root/.ssh/agung.b.sorlawan_id_ed25519
}

case "${1:-}" in
push) push ;;
setup) setup ;;
*)
  echo "usage: $0 push|setup" >&2
  exit 1
  ;;
esac
