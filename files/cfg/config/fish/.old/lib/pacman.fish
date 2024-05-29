# list and describe installed package
alias pac="\
pacman -Qq |\
fzf --preview 'pacman -Qil {}' --layout=reverse --bind 'enter:execute(pacman -Qil {} | less)'"

# last updated/installed package
alias pal="expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort | tail -n 20"
