$env.WLAN_IFACE = "wlp0s20f3"
$env.TERM = "xterm-256color"

$env.EDITOR = "nvim"
$env.VISUAL = $env.EDITOR
$env.XDG_CONFIG_HOME = ($env.HOME | path join ".config")
$env.XDG_DATA_HOME = ($env.HOME | path join ".local/share")
$env.MANPAGER = "nvim +Man! -c 'set signcolumn=no ft=man nomod nolist nonumber norelativenumber signcolumn=no cmdheight=1 laststatus=1 hidden autowrite noswapfile statuscolumn='"
$env.GIT_ASKPASS = ""

# @rust
$env.CARGO_TARGET_DIR = ($env.HOME | path join ".cargo_build_artifacts")
$env.CARGO_REGISTRIES_CRATES_IO_PROTOCOL = "sparse"
#------------------------------------------------------------------------------

# @go
# $env.GOPATH = ($env.HOME | path join "go")
# set -x PATH "$GOROOT/bin:$GOPATH/bin" "$PATH"
#------------------------------------------------------------------------------

# @xdg
$env.XDG_DESKTOP_DIR = ($env.HOME | path join "desktop")
$env.XDG_DOWNLOAD_DIR = ($env.HOME | path join "downloads")
$env.XDG_TEMPLATES_DIR = ($env.HOME | path join "templates")
$env.XDG_PUBLICSHARE_DIR = ($env.HOME | path join "public")
$env.XDG_DOCUMENTS_DIR = ($env.HOME | path join "documents")
$env.XDG_MUSIC_DIR = ($env.HOME | path join "music")
$env.XDG_PICTURES_DIR = ($env.HOME | path join "pictures")
$env.XDG_VIDEOS_DIR = ($env.HOME | path join "videos")
#------------------------------------------------------------------------------

# @other
$env.BRP = "-44"
#------------------------------------------------------------------------------
