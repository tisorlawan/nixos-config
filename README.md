## Wallpapers

https://github.com/debraj-80/wall-archive

## Agent usage dashboard

Codex and Claude token usage at http://127.0.0.1:8770, grouped by model and WIB
day. The React app lives in `files/cfg/local/share/agent-usage-stats`; its systemd
unit lives in `files/cfg/config/systemd/user/agent-usage-stats.service`.

`links.sh` builds, links and starts it. To set up only the dashboard:

```sh
bash ~/.rice/install-script/setup-agent-usage-stats.sh
```

This creates `~/.local/share/agent-usage-stats`, the compatibility link
`~/tools/codex-usage-stats`, and `~/.config/systemd/user/agent-usage-stats.service`.
The user service is enabled at login. To relink and restart an existing build,
use `--skip-build`. Dependencies, builds and usage snapshots are ignored by Git.
