# https://github.com/rebelot/kanagawa.nvim/blob/master/extras/kanagawa.fish
set -l foreground DCD7BA normal
set -l selection 2D4F67 brcyan
set -l comment 727169 brblack
set -l red C34043 red
set -l orange FF9E64 brred
set -l yellow C0A36E yellow
set -l green 76946A green
set -l purple 957FB8 magenta
set -l cyan 7AA89F cyan
set -l pink D27E99 brmagenta

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment



function update_starship_theme
    # Path to your starship theme generator script
    set script_path $HOME/.scripts/my-starship

    # Check if script exists
    if test -x $script_path
        $script_path
    else
        echo "Starship theme script not found at $script_path"
        return 1
    end
end

function set_color_mode
    if test (count $argv) -eq 0
        echo "Usage: set_color_mode [light|dark]"
        return 1
    end

    set mode $argv[1]

    if test "$mode" != "light" -a "$mode" != "dark"
        echo "Invalid mode. Use 'light' or 'dark'"
        return 1
    end

    set -gx COLOR $mode

    echo $mode > ~/.color

    update_starship_theme

    echo "Color mode set to $mode"
end

function update_starship_on_startup
    set current_mode $COLOR

    if test -z "$current_mode" -a -f ~/.color
        set current_mode (cat ~/.color 2>/dev/null | string trim)
    end

    # Check if we have a stored mode and if starship config exists
    if test -n "$current_mode" -a -f ~/.config/starship.toml
        # Get modification time of ~/.color (if exists) and starship config
        if test -f ~/.color
            set color_file_time (stat -c %Y ~/.color 2>/dev/null || echo 0)
            set starship_time (stat -c %Y ~/.config/starship.toml 2>/dev/null || echo 0)

            if test $color_file_time -gt $starship_time
                update_starship_theme >/dev/null
            end
        end
    else
        update_starship_theme >/dev/null
    end
end

update_starship_on_startup

alias light='set_color_mode light'
alias dark='set_color_mode dark'
