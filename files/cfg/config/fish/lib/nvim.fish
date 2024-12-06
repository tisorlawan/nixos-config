set -x PATH "$PATH" "$HOME/.local/share/nvim/mason/bin"
set -x MANPAGER "nvim +Man! -c 'set signcolumn=no ft=man nomod nolist nonumber norelativenumber signcolumn=no cmdheight=1 laststatus=1 hidden autowrite noswapfile statuscolumn='"

alias W='nvim -c "setlocal buftype=nofile bufhidden=wipe" -c "nnoremap <buffer> q :q!<CR>" -'
alias lvim='nvim -c "normal '\''0"'
alias teln="rg --files | fzf --border-label='[ File search ]' --preview 'bat --style=numbers --color=always --line-range :100 {}' | xargs nvim "
alias nnvim="NVIM_APPNAME=nvim2 nvim"
