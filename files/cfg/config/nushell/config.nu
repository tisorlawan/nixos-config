$env.config.show_banner = false
$env.config.buffer_editor = "neovim"
$env.config = {
  history: {
    file_format: sqlite
    sync_on_enter: false
    isolation: true
    max_size: 500000
  }
}

alias mv = ^mv
alias cp = ^cp
alias rm = ^rm

def gcloudc [--print] {
    let token = (gcloud auth print-access-token | str trim)
    if $print {
        print $token
    } else {
        $token | xclip -selection clipboard
    }
}

def l [] {
    ls | sort-by modified
}

def ll [] {
    ls -l | sort-by type | select name type mode user group modified
}

def lt [--level (-L): int] {
    if ($level | is-empty) {
        eza --tree
    } else {
        eza --tree -L $level
    }
}

def cq [] { cargo run --quiet }
def cqr [] { cargo run --quiet --release }
def cr [] { cargo run }
def crr [] { cargo run --release }

source ~/.config/nushell/.zoxide.nu
source ~/.config/nushell/.atuin.nu

$env.config.keybindings = (
  $env.config.keybindings
  | where not (
      $it.name == "atuin" and
      $it.keycode == "up"
    )
)


$env.PATH = ([("~/.scripts" | path expand)] ++ $env.PATH)
$env.PATH = ([("~/.opencode/bin" | path expand)] ++ $env.PATH)
