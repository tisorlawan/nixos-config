set fish_greeting # Remove greeting
fish_vi_key_bindings # Use vi mode
function fish_mode_prompt
end # Disable vim mode indicator

set -x TERM xterm-256color
set -x LANG "en_US.UTF-8"
set -x EDITOR nvim
set -x VISUAL "$EDITOR"
