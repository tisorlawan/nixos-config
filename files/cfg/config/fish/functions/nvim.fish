# In a Tern pane, `nvim` or `nvim FILE` reuses a Neovim that already runs in another pane of the
# same Tern session with the same working directory: FILE opens there and Tern switches to that
# pane. Neovim's own working directory is compared, which can differ from its shell's.
# Flags, several files, no match, or no Tern start a new Neovim as usual.
function nvim --wraps nvim --description 'nvim; reuses a Neovim in the same Tern session and directory'
    if not set -q TERN_PANE; or test (count $argv) -gt 1; or string match -qr '^[-+]' -- $argv
        command nvim $argv
        return
    end

    set -l session_panes (command tern ls --json 2>/dev/null | jq -r --arg pane $TERN_PANE \
        '.sessions[] | select([.tabs[].blocks[].id | tostring] | index($pane)) | .tabs[].blocks[].id')
    set -l cwd (path resolve -- $PWD)

    # The remote clients run --headless with stdin from /dev/null. Without --headless, a client
    # started from an interactive shell writes its answer to the terminal, not stdout, and
    # under timeout it is stopped for touching the terminal from the background and hangs.
    for socket in $XDG_RUNTIME_DIR/nvim.*.0
        # Prints "CWD PANE"; a Neovim that has exited leaves a socket that refuses the connection.
        # timeout runs the nvim binary, not this function.
        set -l info (timeout --foreground 1 nvim --headless --server $socket \
            --remote-expr 'getcwd() .. " " .. $TERN_PANE' </dev/null 2>/dev/null | string split -r -m1 ' ')
        test (count $info) -eq 2; or continue

        set -l pane $info[2]
        if test "$pane" != "$TERN_PANE"; and contains -- $pane $session_panes; and test (path resolve -- $info[1]) = "$cwd"
            if test (count $argv) -eq 1
                command nvim --headless --server $socket --remote (path resolve -- $argv[1]) </dev/null
            end
            command tern focus $pane >/dev/null
            return
        end
    end

    command nvim $argv
end
