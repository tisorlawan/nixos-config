function copy_pwd
    pwd | xclip -selection clipboard
end

alias jql="jq -C | less -R"
alias lg="lazygit"
alias rgu="rg -uuu -g '!static' -g '!.venv' -g '!node_modules'"
alias r="rsync -avzP"
alias kvpn="sudo python ~/Prosa/projects/kominfo/vm/connect-vpn.py"
alias zbr="zig build run"
alias y="yazi"


##-- DOCKER --##
alias dcl="sudo docker container ls"
alias di="sudo docker images"
alias drmi="sudo docker rmi"
alias dcup="sudo docker compose up"
alias dcupd="sudo docker compose up -d"
alias dcd="sudo docker compose down"

##-- GIT --##
alias gap="git add -p"

##-- MPV --##
alias mpvr="mpv --no-resume-playback"
alias ms="mpv --shuffle --no-resume-playback"
alias rmpv="find . -type f | shuf | head -n 1 | xargs -I {} mpv --no-resume-playback {}"

##-- NIX --##
alias nix-generations-ls="nix profile history --profile /nix/var/nix/profiles/system"
alias nix-generations-rm="sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than"
alias ns="nix-shell --run fish"
alias ds="devenv shell fish"
alias fs="nix develop --command fish"

##-- NVIM --##
alias W='nvim -c "setlocal buftype=nofile bufhidden=wipe" -c "nnoremap <buffer> q :q!<CR>" -'
alias lvim='nvim -c "normal '\''0"'
alias teln="rg --files | fzf --border-label='[ File search ]' --preview 'bat --style=numbers --color=always --line-range :100 {}' | xargs nvim "
alias nnvim="NVIM_APPNAME=nvim2 nvim"

##-- PYTHON --##
alias p="python"
alias a="source .venv/bin/activate.fish"
alias d="deactivate"
function py_prefix
    python -c "import sys; print(sys.prefix)"
end
if type -q uv
    uv generate-shell-completion fish | source
end

##-- RUST --##
alias cb="cargo build"
alias cbr="cargo build --release"
alias cr="cargo run"
alias crr="cargo run --release"
alias crb="cargo run --bin"
alias cq="cargo run -q"
alias cqr="cargo run -q --release"
alias ct="cargo nextest run"
alias ctr="cargo nextest run --release"
alias cdo="cargo doc --open"
alias ccc='cargo clippy --all-targets --all-features -- -D warnings -D clippy::pedantic -A clippy::must-use-candidate -D clippy::unwrap_used -A clippy::uninlined_format_args -A clippy::module_name_repetitions -A clippy::wildcard_imports -A clippy::too-many-lines'

##-- YT-DLP --##
alias yd="yt-dlp"
alias ydv="yt-dlp -f 'bv*[height<=1080][ext=mp4]+ba/b' --no-playlist"
alias ydv720="yt-dlp -f 'bv*[height<=720][ext=mp4]+ba/b' --no-playlist"
alias ydv720compat="yt-dlp -f '230+233' --no-playlist --no-playlist"
alias ydp="yt-dlp -f 'bv*[height<=1080][ext=mp4]+ba/b' -o '%(playlist_index)s [%(playlist_id)s]  - %(title)s.%(ext)s'"
alias yda="yt-dlp -f '[ext=mp4]+ba/b' --extract-audio --no-playlist"
