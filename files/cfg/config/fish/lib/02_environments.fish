set -x TERM xterm-256color
set -x LANG "en_US.UTF-8"
set -x EDITOR nvim
set -x VISUAL "$EDITOR"

set -x GIT_ASKPASS ""

set -x GOPATH "$HOME/go"
set -x PATH "$GOROOT/bin:$GOPATH/bin" "$PATH"

set -x MANPAGER "nvim +Man! -c 'set signcolumn=no ft=man nomod nolist nonumber norelativenumber signcolumn=no cmdheight=1 laststatus=1 hidden autowrite noswapfile statuscolumn='"

set -x PYTHONDONTWRITEBYTECODE 1
set -x _TYPER_STANDARD_TRACEBACK 1

set -x CARGO_TARGET_DIR "$HOME/.cargo_build_artifacts"
set -x CARGO_REGISTRIES_CRATES_IO_PROTOCOL sparse

export XDG_DESKTOP_DIR="$HOME/desktop"
export XDG_DOWNLOAD_DIR="$HOME/downloads"
export XDG_TEMPLATES_DIR="$HOME/templates"
export XDG_PUBLICSHARE_DIR="$HOME/public"
export XDG_DOCUMENTS_DIR="$HOME/documents"
export XDG_MUSIC_DIR="$HOME/music"
export XDG_PICTURES_DIR="$HOME/pictures"
export XDG_VIDEOS_DIR="$HOME/videos"

set -x DIRENV_LOG_FORMAT ""

set -x UV_HTTP_TIMEOUT 300

set -x PASSLOCK_FILE $HOME/.rice/passlock.enc

set -l _color_mode $COLOR
if test -z "$_color_mode"; and test -f "$HOME/.color"
    set _color_mode (string trim (cat "$HOME/.color" 2>/dev/null))
end

if test "$_color_mode" = light
    set -x BAT_THEME Coldark-Cold
else
    set -x BAT_THEME TwoDark
end
