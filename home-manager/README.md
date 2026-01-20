● Apps likely to have GPU/OpenGL issues (consider system install):
┌──────────────────┬──────┬────────┬──────────────────────────────────────────┐
│ Package │ Line │ Risk │ Reason │
├──────────────────┼──────┼────────┼──────────────────────────────────────────┤
│ neovide │ 270 │ HIGH │ GPU-accelerated Neovim, uses Skia/OpenGL │
├──────────────────┼──────┼────────┼──────────────────────────────────────────┤
│ picom │ 60 │ HIGH │ OpenGL compositor │
├──────────────────┼──────┼────────┼──────────────────────────────────────────┤
│ telegram-desktop │ 277 │ HIGH │ Qt/OpenGL │
├──────────────────┼──────┼────────┼──────────────────────────────────────────┤
│ postman │ 88 │ HIGH │ Electron (same engine as Brave) │
├──────────────────┼──────┼────────┼──────────────────────────────────────────┤
│ sioyek │ 272 │ MEDIUM │ GPU-accelerated PDF viewer │
├──────────────────┼──────┼────────┼──────────────────────────────────────────┤
│ evince │ 271 │ MEDIUM │ PDF viewer │
├──────────────────┼──────┼────────┼──────────────────────────────────────────┤
│ xournalpp │ 276 │ MEDIUM │ Can use GPU │
└──────────────────┴──────┴────────┴──────────────────────────────────────────┘
Recommended to install via system (apt):

- brave-browser
- mpv
- alacritty (or use system terminal)
- telegram-desktop
- postman (use snap/flatpak)

Safe in nix (CLI, no GPU):

- All dev tools, compilers, language servers
- CLI utilities (bat, ripgrep, fzf, etc.)
- neovim (terminal version)
- ffmpeg (CLI)

Want me to list the apt/snap commands for the recommended ones?
