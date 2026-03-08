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
alias p8 = ping 8.8.8.8
alias rn = sudo systemctl restart NetworkManager
alias nn = nmtui-connect
alias cat = bat --plain
alias r = rsync -avzP
alias lg = lazygit
alias a = overlay use .venv/bin/activate.nu

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


def --env poetry-shell [] {
    let venv = (poetry env info --path | str trim)
    let bin = ($venv | path join "bin")

    $env.VIRTUAL_ENV = $venv
    $env.PATH = ($env.PATH | prepend $bin)

    print $"Activated poetry env: ($venv)"
}

def --env poetry-deactivate [] {
    if "VIRTUAL_ENV" in ($env | columns) {
        let bin = ($env.VIRTUAL_ENV | path join "bin")
        $env.PATH = ($env.PATH | where $it != $bin)
        hide-env VIRTUAL_ENV
        print "Poetry environment deactivated"
    }
}

def --env uv-glsdk [] {
    $env.UV_INDEX_GEN_AI_INTERNAL_USERNAME = "oauth2accesstoken"
    $env.UV_INDEX_GEN_AI_INTERNAL_PASSWORD = (gcloud auth print-access-token | str trim)
    print "uv auth configured (expires in ~1 hour)"
}
alias pss = poetry-shell
alias top = btop

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
$env.PATH = ([("~/.bun/bin" | path expand)] ++ $env.PATH)
