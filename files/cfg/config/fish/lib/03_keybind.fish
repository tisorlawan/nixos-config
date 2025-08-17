# copy current command to clipboard
bind -M insert \cx copy_pwd
bind --preset \cp up-or-search

function backward-kill-to-whitespace
    set -l pos (commandline --cursor)
    set -l line (commandline)

    if test $pos -eq 0
        return
    end

    # Get text before cursor
    set -l before (string sub --length $pos $line)

    # First, skip any whitespace immediately before cursor
    set -l trimmed_before (string replace -r '[ \t\n]*$' '' $before)

    if test (string length $trimmed_before) -eq 0
        # Everything before cursor is whitespace, delete to beginning
        set -l new_line (string sub --start (math $pos + 1) $line)
        commandline --replace $new_line
        commandline --cursor 0
        return
    end

    # Now find the last whitespace in the trimmed text
    set -l whitespace_pos (string match -r '.*[ \t\n]' $trimmed_before | string length)

    if test -z "$whitespace_pos"
        # No whitespace found, delete to beginning of line
        set whitespace_pos 0
    end

    # Delete from whitespace position to cursor
    set -l new_line (string sub --length $whitespace_pos $line)(string sub --start (math $pos + 1) $line)
    commandline --replace $new_line
    commandline --cursor $whitespace_pos
end

bind alt-backspace backward-kill-to-whitespace

bind alt-backspace backward-kill-to-whitespace
