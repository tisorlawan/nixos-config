$env.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense"

if not (which carapace | is-empty) {
    carapace _carapace nushell | save --force ~/.config/nushell/.carapace.nu
}

source ~/.config/nushell/.carapace.nu
