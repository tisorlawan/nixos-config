for f in $HOME/.config/fish/lib/*.fish
    source $f
end

# Basic aliases
alias cat="bat --plain"
alias l="eza -1"
alias ll="eza -l"
alias lt="eza -T"

alias p8="ping 8.8.8.8"
alias rn="sudo systemctl restart NetworkManager"
alias nn="nmtui-connect"

alias clip="xclip -selection clipboard"
alias top="btop"

set -x XDG_CURRENT_DESKTOP GNOME

# Integrations
zoxide init fish | source
starship init fish | source

## command not found
set distro $(cat /etc/*-release | grep "^ID=" | cut -d "=" -f2); [ "$distro" = arch ] && source /usr/share/doc/find-the-command/ftc.fish
