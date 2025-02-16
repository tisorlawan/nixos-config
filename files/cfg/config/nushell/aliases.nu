use std/dirs shells-aliases *

alias top = btop
def l [] { ls | sort-by name }
def ll  [] { ls | sort-by modified | reverse }
def lt [ --level: int ] {
	if ($level | is-empty) {
		eza --tree
	} else {
		eza --tree -L ($level | into string)
	}
}
alias c = bat --plain
def gittoken [] { cat ~/.gittoken | wl-copy }
alias lg = lazygit
alias gap = git add -p
def diff_prompt [] { code2prompt . --diff -t /home/tiso/software/3p/code2prompt/templates/write-git-commit.hbs --no-clipboard -o /tmp/prompt ; cat /tmp/prompt | wl-copy }
alias r = rsync -avzP
alias rn = sudo systemctl restart NetworkManager
alias nn = nmtui-connect
alias p8 = ping 8.8.8.8
#------------------------------------------------------------------------------

# @git
alias gis = git status
#------------------------------------------------------------------------------

# @python
alias p = python
alias a = overlay use .venv/bin/activate.nu
alias d = deactivate
def python_prefix [] { python -c "import sys; print(sys.prefix)" }
#------------------------------------------------------------------------------

# @rust
alias cb = cargo build
alias cbr = cargo build --release
alias cr = cargo run
alias crr = cargo run --release
alias crb = cargo run --bin
alias cq = cargo run -q
alias cqr = cargo run -q --release
alias ct = cargo nextest run
alias ctr = cargo nextest run --release
alias cdo = cargo doc --open
alias ccc = cargo clippy --all-targets --all-features -- -D warnings -D clippy::pedantic -A clippy::must-use-candidate -D clippy::unwrap_used -A clippy::uninlined_format_args -A clippy::module_name_repetitions -A clippy::wildcard_imports -A clippy::too-many-lines
#------------------------------------------------------------------------------

# @nix
alias nix-generations-ls = nix profile history --profile /nix/var/nix/profiles/system
alias nix-generations-rm = sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than
alias ns = nix-shell --run nu
alias ds = devenv shell nu
alias fs = nix develop --command nu
#------------------------------------------------------------------------------

# @zig
alias zbr = zig build run
#------------------------------------------------------------------------------

# @mpv
alias mpvr = mpv --no-resume-playback
alias ms = mpv --shuffle --no-resume-playback
def rmpv [] { ^find . -type f | shuf | head -n 1 | xargs -I xx mpv --no-resume-playback xx }
#------------------------------------------------------------------------------

# @yt-dlp
alias yd = yt-dlp
alias ydv = yt-dlp -f 'bv*[height<=1080][ext=mp4]+ba/b' --no-playlist
alias ydp = yt-dlp -f 'bv*[height<=1080][ext=mp4]+ba/b' -o '%(playlist_index)s [%(playlist_id)s]  - %(title)s.%(ext)s'
alias yda = yt-dlp -f '[ext=mp4]+ba/b' --extract-audio --no-playlist
#------------------------------------------------------------------------------

# @other
alias hbook = sh -c 'nohup sioyek ~/todos/haskell_from_first_principle/haskell_programming.pdf >/tmp/nohup.out &'
alias h2book = sh -c 'nohup sioyek ~/todos/effective_haksell/effective-haskell.pdf >/tmp/nohup.out &'
alias sicp = sh -c 'nohup sioyek ~/todos/sicp/sicp.pdf >/tmp/nohup.out &'
#------------------------------------------------------------------------------

# @scheme
def sci [
    filename: string  # The .scm file to execute
] {
    let cmd = ['(load "' $filename '")'] | str join ""
    ^racket -l sicp --repl -e $cmd
}
