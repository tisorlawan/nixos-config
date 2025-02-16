$env.config.buffer_editor = "nvim"
$env.config.show_banner = false
$env.config.edit_mode = "vi"

$env.config.history = {
    max_size: 500000
    sync_on_enter: false
    isolation: true
    file_format: "sqlite"
}

$env.config.completions.external = {
    enable: true
    max_results: 200
    completer: {|spans| carapace $spans.0 nushell ...$spans | from json }
}

source ($nu.default-config-dir | path join "env.nu")
source ($nu.default-config-dir | path join "paths.nu")
source ($nu.default-config-dir | path join "aliases.nu")
source ($nu.default-config-dir | path join ".zoxide.nu")
source ($nu.default-config-dir | path join ".atuin.nu")

# @uv
# uv generate-shell-completion nushell o> ($nu.default-config-dir | path join ".uv.nu")
source ($nu.default-config-dir | path join ".uv.nu")
#------------------------------------------------------------------------------

# @starship
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
#------------------------------------------------------------------------------
