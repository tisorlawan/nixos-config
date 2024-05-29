set fish_greeting # Remove greeting
fish_vi_key_bindings # Use vi mode
function fish_mode_prompt
end # Disable vim mode indicator

set -x TERM xterm-256color
set -x LANG "en_US.UTF-8"
set -x EDITOR nvim
set -x VISUAL "$EDITOR"
set -x SUDO_ASKPASS "$HOME/.scripts/askpass"


set PATH "$HOME/.local/bin" "$HOME/.scripts/" "$PATH"
if type -q go
    set PATH "$GOROOT/bin:$GOPATH/bin" "$PATH"
    set -x GOPATH "$HOME/go"
    set -x GOROOT /usr/lib/go
end
set PATH "$HOME/.cargo/bin" "$PATH"
set PATH "$HOME/.ghcup/bin" "$PATH"
set JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
set PATH "$PATH" "$JAVA_HOME/bin/"
set PATH "$PATH" "$HOME/.local/share/nvim/mason/bin"
set PATH "$PATH" "$HOME/.local/share/nvim/distant.nvim/bin"
if type -q rustup
    set PATH "$(rustup show home)/toolchains/$(rustup show active-toolchain | cut -d' ' -f1)/bin" "$PATH"
    set -x CARGO_TARGET_DIR "$HOME/.cargo_build_artifacts"
end

set -x RUSTC_WRAPPER /bin/sccache


set -x LD_LIBRARY_PATH "/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
set -x DEBUGINFOD_URLS "https://debuginfod.archlinux.org"

set -x OMF_CONFIG "$HOME/.config/fish/omf"
set -x BAT_THEME TwoDark

# Ibus and keyboard input config
set -x GTK_IM_MODULE ibus
set -x XMODIFIERS "@im=ibus"
set -x QT_IM_MODULE ibus

set -x PYTHONDONTWRITEBYTECODE 1

set -x METATRADER_HOST_PATH "$HOME/MetaTrader"

set -x _ZO_MAXAGE 30000

set -x CARGO_REGISTRIES_CRATES_IO_PROTOCOL sparse

set -x _TYPER_STANDARD_TRACEBACK 1

# ALIASES
alias less='less -R'
alias files="rg --files --hidden --glob '!.git/*'"
alias b="bat"
alias l="eza -1"
alias ll="eza -l"
alias l1="eza -1"
alias lt="eza --tree"
alias l2="eza --tree -L 2"
alias l3="eza --tree -L 3"
alias et="eza -T"
alias sl="l"
alias e="$EDITOR $HOME/.config/fish/config.fish"
alias E=". $HOME/.config/fish/config.fish && echo config is sourced successfully"
alias a=". .venv/bin/activate.fish"
alias aa=". $HOME/.venv/bin/activate.fish"

alias de="deactivate"
alias clip="xclip -selection clipboard"
alias h="prettier --stdin-filepath /tmp/test.html | bat --style=plain -l html"
alias lg="lazygit"
alias fs="files | fzy -l 80"
alias process="\
ps axww -o pid,user,%cpu,%mem,start,time,command |\
grep -E -v ' root.*\[' |\
fzy -l 80|\
sed 's/^ *//' |\
sed -E 's/^([0-9]+)\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+.*)/\1 \2/g'"
alias m="sudo mount -t ntfs-3g -o permissions UUID=66A7F9715F509C93  /mnt"
alias um="sudo umount /mnt"
alias d="gocryptfs /media/tiso/Tiso/p ~/private"
alias ud="umount ~/private"
alias g="git"
alias o="open"
alias p="python"
alias n="nvim"
alias pn="poetry run nvim"
alias hx="helix"
alias wi="wezterm imgcat"

alias sxfce="xinit /home/tiso/.xinitrc xfce4 -- /etc/X11/xinit/xserverrc :0 vt1 -keeptty -auth /tmp/serverauth.xfce4"
alias sgnome="xinit /home/tiso/.xinitrc gnome-session -- /etc/X11/xinit/xserverrc :0 vt1 -keeptty -auth /tmp/serverauth.xfce4"

alias mpvr="mpv --no-resume-playback"
alias mpvrs="mpv --no-resume-playback --shuffle"
alias ms="mpv --shuffle --no-resume-playback"

alias rgf="rg --files | rg"
alias rguf="rg -uuu --files | rg"

alias p8="ping 8.8.8.8"

alias docker_clean_images="docker rmi (docker images -a --filter=dangling=true -q)"
alias docker_clean_ps="docker rm (docker ps --filter=status=exited --filter=status=created -q)"

alias da='date "+%d %b %Y %H:%M"'

alias pf="poetry run ./scripts/format.sh"
alias pl="poetry run ./scripts/lint.sh"
alias prr="poetry run ./scripts/run.sh"
alias por="poetry run"
alias pp="poetry run python"
alias pss="poetry shell"

alias kg="kubectl get"
alias kd="kubectl describe"
alias kdel="kubectl delete"

alias tnode="npx ts-node-dev --respawn"

alias gx="GIT_EXTERNAL_DIFF=difft git"

alias gpu="sudo intel_gpu_top"

alias snn="npx shadcn-ui@latest"

alias kvpn="sudo python ~/Prosa/projects/kominfo/vm/connect-vpn.py"

alias yayd="yay --editmenu --nodiffmenu --save"
alias udate="sudo ntpdate ntp.ubuntu.com"
alias gpu="sudo intel_gpu_top"


alias ipynb_clear="fd ipynb | xargs -I {} jupyter nbconvert --clear-output --inplace {}"

alias rr="rye run"
function rl
    rye run 2>&1 | grep '(' | awk '{print $1}' | sort
end

alias pudb="python -m pudb --log-errors pudberrors.log"

function log-backend
    ssh -i ~/.ssh/sso-prosa agung.sorlawan@43.245.191.194 -t "ssh -i ~/.ssh/sso-prosa text-user@10.181.131.244 -t 'docker-compose -f /share/text/chatbot-platform/conversa/chatbot/docker-compose-backend.yml logs --tail 1000 -f'"
end

function db-develop
    ssh -i ~/.ssh/sso-prosa agung.sorlawan@43.245.191.194 -t "ssh -i ~/.ssh/sso-prosa text-user@10.181.131.244 -t 'docker exec -it chatbot-postgres psql -U chatbot_postgres -d chatbot_development'"
end


function copy_pwd
    pwd | xclip -selection clipboard
end
bind -M insert \cx copy_pwd

# bind -M insert \cy ~/.scripts/tmux-switch-session


for f in $HOME/.config/fish/lib/*.fish
    source $f
end

export MANPAGER="nvim +Man! -c 'set signcolumn=no ft=man nomod nolist nonumber norelativenumber signcolumn=no cmdheight=1 laststatus=1 hidden autowrite noswapfile statuscolumn='"

set distro $(cat /etc/*-release | grep "^ID=" | cut -d "=" -f2); [ "$distro" = arch ] && source /usr/share/doc/find-the-command/ftc.fish

zoxide init fish | source
starship init fish | source

function py_prefix
    python -c "import sys; print(sys.prefix)"
end


set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

set -Ua fish_user_paths "$HOME/.rye/shims"


set HOME_MANAGER "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
if test -f "$HOME_MANAGER"
    fenv source "$HOME_MANAGER"
end

if test -f $HOME/.nix-profile/etc/profile.d/nix.fish
    . $HOME/.nix-profile/etc/profile.d/nix.fish
    export PATH="$HOME/.nix-profile/bin:$PATH"
end

set -x UV_HTTP_TIMEOUT 3600
