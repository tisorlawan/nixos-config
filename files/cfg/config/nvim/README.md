# Cursor padding

[scrollEOF.nvim](https://github.com/Aasim-A/scrollEOF.nvim) extends `scrolloff` past the end of a file.
The cursor keeps four screen rows below it in normal and insert modes, when the window has sufficient space.
The plugin does not add blank lines to the file. It does not adjust floating windows.
Change `vim.opt.scrolloff` in `init.lua` to adjust the margin.

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

The default layout is a right split. The other choices are a bottom split, a floating window, and the full current window.
The layout selection applies when the runner opens its next terminal window.

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
They cover command input, edits, hidden execution, all layouts, terminal closure, exit status, and the quit guard.
They also check split ratios and persistence across two Neovim processes with different terminal sizes.
