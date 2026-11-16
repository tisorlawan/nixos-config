# In a Tern pane, `tern FILE[:LINE[:COL]]` opens FILE in a split to the right, focuses it, and zooms it.
# Every other use of `tern` runs the binary unchanged.
function tern --wraps tern --description 'tern; FILE opens in a zoomed split to the right'
    if set -q TERN_PANE; and test (count $argv) -eq 1; and test -f (string replace -r ':\d+(:\d+)?$' '' -- $argv[1])
        command tern open --split right $argv[1]; and command tern ctl zoom >/dev/null
        return
    end

    command tern $argv
end
