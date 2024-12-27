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

# Integrations
zoxide init fish | source
starship init fish | source

atuin init fish --disable-up-arrow | source
