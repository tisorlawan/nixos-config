#!/usr/bin/env bash
# Link, build and start the Codex/Claude usage dashboard without running all of links.sh.
set -euo pipefail

skip_build=false
case "${1:-}" in
  '') ;;
  --skip-build) skip_build=true ;;
  *) printf 'Usage: %s [--skip-build]\n' "$0" >&2; exit 2 ;;
esac
if (( $# > 1 )); then
  printf 'Usage: %s [--skip-build]\n' "$0" >&2
  exit 2
fi

rice_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
app_source="$rice_root/files/cfg/local/share/agent-usage-stats"
unit_source="$rice_root/files/cfg/config/systemd/user/agent-usage-stats.service"

link_file() {
  local source="$1" destination="$2"
  if [[ -e "$destination" && ! -L "$destination" ]]; then
    printf 'Cannot replace existing file or directory: %s\n' "$destination" >&2
    return 1
  fi
  mkdir -p -- "$(dirname -- "$destination")"
  ln -sfn -- "$source" "$destination"
}

if [[ ! -f "$app_source/package-lock.json" || ! -f "$unit_source" ]]; then
  printf 'Dashboard source or service unit is missing from %s\n' "$rice_root" >&2
  exit 1
fi

if [[ "$skip_build" == false ]]; then
  if ! command -v npm >/dev/null 2>&1; then
    printf 'Install Node.js 22.12+ and npm before setting up the dashboard.\n' >&2
    exit 1
  fi
  (
    cd -- "$app_source"
    npm ci --no-fund --no-audit
    npm run build
  )
elif [[ ! -f "$app_source/dist/index.html" ]]; then
  printf 'No production build exists. Run this script without --skip-build.\n' >&2
  exit 1
fi

link_file "$app_source" "$HOME/.local/share/agent-usage-stats"
link_file "$app_source" "$HOME/tools/codex-usage-stats"
link_file "$unit_source" "$HOME/.config/systemd/user/agent-usage-stats.service"

systemctl --user daemon-reload
systemctl --user enable --force agent-usage-stats.service
systemctl --user restart agent-usage-stats.service
printf 'Agent usage dashboard: http://127.0.0.1:8770/\n'
