# Colorschemes

Dark mode uses the local `tiso-black` theme. Light mode uses `tiso-light`.
Both themes share their highlight rules and palettes in `lua/tiso.lua`.
Keywords use bold text. Most syntax uses neutral colors.

| Role | `tiso-black` | `tiso-light` |
| --- | --- | --- |
| Opaque background | `#101010` | `#fafafa` |
| Text | `#dedede` | `#242424` |
| Comments | `#ee66ff` | `#9c239e` |
| Strings and extra cursors | `#b5e890` | `#326b26` |
| Errors | `#ff5f5f` | `#b42318` |
| Warnings | `#ffad42` | `#995700` |
| Extra Visual selections | `#24351d` | `#e0ecd9` |

Mode selection uses `COLOR` or `LC_COLOR`, with `~/.color` as the fallback.
Values that contain `light` select light mode. All other values select dark mode.

Press `Space t t` to toggle transparency for the current mode.
Both modes start transparent. Each mode keeps its own transparency state for the session.
Completion menus, documentation popups, and scrollbar gutters follow the same transparency state.
The selected completion keeps a solid background for contrast.
Use `:colorscheme tiso-black` or `:colorscheme tiso-light` to load a theme directly.
For an opaque direct load, set `vim.g.tiso_black_transparent` or `vim.g.tiso_light_transparent` to `false` before the command.

Extra cursors use black text in dark mode and white text in light mode.
Their Visual selections use a green tint, distinct from the main gray selection.
Press `Q` to add or remove an extra cursor. Press `Ctrl-L` to clear extra cursors.

Tern (`TERM_PROGRAM=tern`) uses Neovim-rendered cursor highlights instead of its advertised Kitty cursor protocol.
The override also handles later capability replies. Kitty keeps its native cursor protocol.
This Tern-only override uses the private `vim._core.mcursor.tty_cursors` API in Neovim 0.13 nightly.

# Zen mode

Neovim starts in Zen mode. Press `Space z z` to toggle it.
Zen mode hides line numbers, sign columns, the status line, the tab line, the winbar, and the command line.
Exit Zen mode to restore the previous bar settings and show line numbers.
Terminal buffers keep line numbers hidden. Org buffers keep a visible command line when they open.

# Symbol search

Press `Space f s` to search symbols in the current file with Snacks.
Press `Space f S` to search symbols in the workspace with Snacks.
Both shortcuts require an attached language server that supports the corresponding symbol request.

# Git

Press `Space g G` in normal mode to show or hide LazyGit.
Inside LazyGit, press `Ctrl-g` first to enter terminal-normal mode, then press `Space g G`.
The shortcut does not intercept terminal input, so spaces in commit messages have no key-sequence delay.
The toggle keeps the LazyGit process active. Press `q` in LazyGit to exit.
`Space g g` still opens Neogit.

The LazyGit integration uses the existing Snacks plugin and requires the `lazygit` executable.

# Cursor padding

[scrollEOF.nvim](https://github.com/Aasim-A/scrollEOF.nvim) extends `scrolloff` past the end of a file.
The cursor keeps four screen rows below it in normal and insert modes, when the window has sufficient space.
The plugin does not add blank lines to the file. It does not adjust floating windows.
Change `vim.opt.scrolloff` in `init.lua` to adjust the margin.

# EOF marker

A dim `[EOF] ----------------` marker appears on a separate display row below the final line of each normal file buffer.
The marker follows edits, undo, and redo. It does not add text or blank lines to the file.
Utility buffers, such as help pages and terminals, do not show the marker.
The standard `~` markers below the end of the buffer are hidden.

# Trailing whitespace

Trailing spaces and tabs use a muted red background in file buffers, including lines that contain only whitespace.
Dark mode uses `#3b2222`. Light mode uses `#ead5d5`. Utility buffers do not show the highlight.
The highlight does not change the text.

Use `:TrimWhitespace` to remove trailing whitespace from the current buffer.
Use `:ToggleAutoTrimWhitespaceOnSave` to enable or disable automatic removal on save. Automatic removal is off by default.

# Python

Python buffers use the Ruff language server to format before each save.
The save waits for the formatter, so the buffer and file contain the same text.
Ruff uses the project's settings in `pyproject.toml`, `ruff.toml`, or `.ruff.toml`.
The `ruff` executable must be on `PATH`. If Ruff is not attached, the save continues without format changes.
This hook only formats Python. It does not apply lint fixes or sort imports.

# Lean 4

Lean support uses [lean.nvim](https://github.com/Julian/lean.nvim) and Blink completion.
Elan selects the Lean version from each project's `lean-toolchain` file. Lake manages dependencies and builds.
The Lean plugin starts the language server and opens the Infoview for proof goals.

Diagnostics remain hidden until save for all filetypes.
Lean still checks edits to keep completion and the Infoview current.
Native diagnostic signs replace Lean's separate source signs. Source proof markers are disabled.

The local leader is two presses of `Space`. Use these keys in a Lean buffer:

- `Space Space i`: Show or hide the Infoview.
- `Space Space Tab`: Move to the Infoview.
- `Space Space s`: Accept the first "Try this" suggestion.
- `Space Space r`: Restart Lean for the current file.
- `Space Space x`: Pin the proof state at the cursor.

Use `gd` for definitions, `K` for interactive hover, and `gra` for code actions.
The interactive hover uses a rounded border. Explicit border options from plugins take precedence.
Unicode abbreviations use a backslash, such as `\forall` for `∀`.
Use `lake build` from the project directory to check the full project.
Run `sh tests/lean.sh` to check the Lean integration with the full config and a real language server.

# Command runner

The leader key is `Space`. Use these keys in normal mode:

| Key | Action |
| --- | --- |
| `<leader>rc` | Enter and run a new command. |
| `<leader>re` | Edit and save the last command without execution. |
| `<leader>rr` | Run the last command. Prompt if no command exists. |
| `<leader>rb` | Run the last command without a visible terminal window. Prompt if no command exists. |
| `<leader>ro` | Show the latest terminal output. |
| `<leader>rf` | Select the terminal layout. |

## Terminal layouts

The default layout is a right split. The other choices are a bottom split, a floating window, the full current window, and `Background (split when error)`.
The layout selection applies to the next run or to output that you open with `<leader>ro`.

With `Background (split when error)`, `<leader>rc` and `<leader>rr` keep the terminal hidden while the command runs.
A zero exit code keeps the terminal hidden. A nonzero exit code opens the output in a right split.
Use `<leader>ro` to show the output at any time. `<leader>rb` keeps the terminal hidden even if the command fails.

Right and bottom splits remember their sizes as separate ratios. Resize a split with normal Neovim commands, such as `:vertical resize 50` or `:resize 12`.
The runner saves each ratio across sessions. It restores the same proportion of the available editor area, even when the terminal size changes.

In a terminal, press `Ctrl-g` to enter normal mode. Then press `q` to hide the terminal. The command continues.
For the full-window layout, `q` restores the previous buffer.
Use `<leader>ro` to return to the output. Output remains available after the command exits.

The runner permits one active command. To stop it, show its terminal and press `Ctrl-c` in terminal mode.
A new run replaces the previous output.
A hidden command still belongs to the Neovim session. The quit guard warns before exit with an active command.

## Commands and saved state

Commands use the configured Neovim shell and the current working directory at invocation.
The configuration uses Fish when it is available.
Cancel the command prompt, or submit only spaces, to keep the command unchanged.

The runner saves the last command, terminal layout, and split ratios across sessions in `stdpath("state")/runner/`.
The command is global, not per project. Repeat uses the current directory, not the directory of the previous run.
The saved files contain plain text. Do not enter secrets directly in a command.
Output does not persist across sessions.

## Checks

From this directory, run:

```sh
sh tests/runner.sh
```

The checks use real terminal jobs and isolated state directories.
They cover command input, edits, hidden execution, all layouts, a split on failure, terminal closure, exit status, and the quit guard.
They also check split ratios and persistence across two Neovim processes with different terminal sizes.
