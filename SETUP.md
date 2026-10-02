# Set up CLIProxyAPI, Codex, and Claude Code

Run these steps once on a new machine. `links.sh` repeats the CLIProxyAPI install and config link, so you can skip steps 2 and 3 if you run it.

## 1. Install the CLIs

```sh
curl -fsSL https://chatgpt.com/codex/install.sh | sh
curl -fsSL https://claude.ai/install.sh | bash
```

## 2. Install CLIProxyAPI

```sh
curl -fsSL https://raw.githubusercontent.com/router-for-me/cliproxyapi-installer/refs/heads/master/cliproxyapi-installer | bash
```

## 3. Use the repository config

Run this from `~/.rice`:

```sh
ln -srf files/cfg/cli-proxy-api/config.yaml ~/cliproxyapi/config.yaml
systemctl --user restart cliproxyapi.service
```

The service listens on `127.0.0.1:8317`. Check it with `systemctl --user status cliproxyapi.service`.

## 4. Point Codex at CLIProxyAPI

T3 Code runs this Codex instance. In T3 Code, open Settings > Providers > Codex, set `CODEX_HOME` to `~/.config/codex-cpa`, and add `CPA_API_KEY` as an instance variable. Use one of the keys under `api-keys` in `config.yaml`.

```sh
mkdir -p ~/.config/codex-cpa
cat > ~/.config/codex-cpa/config.toml <<'EOF'
model = "gpt-6.1-sol"
model_provider = "cpa"

[model_providers.cpa]
name = "CLI Proxy API"
base_url = "http://127.0.0.1:8317/v1"
wire_api = "responses"
env_key = "CPA_API_KEY"
requires_openai_auth = false
EOF
```

## 5. Point Claude Code at CLIProxyAPI

Set these environment variables for Claude Code. Take the token from `api-keys` in `config.yaml`.

```sh
ANTHROPIC_BASE_URL=http://127.0.0.1:8317
ANTHROPIC_AUTH_TOKEN=<key from api-keys>
ANTHROPIC_MODEL=claude-opus-5-5
```

Never commit the token. `files/cfg/cli-proxy-api/config.yaml` already contains the client keys, so treat this repository as private.
