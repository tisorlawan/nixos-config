# Set up CLIProxyAPI, omp, Codex, and Claude Code

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

## 6. Use CLIProxyAPI, OpenCode Go, and Command Code in omp

The global omp configuration uses these files:

- `~/.omp/agent/models.yml` defines `cliproxy` at `http://127.0.0.1:8317/v1` with a fixed list of five models.
- Its command-backed `apiKey` reads the first client key from `~/cliproxyapi/config.yaml` through Bun. Do not copy the key into the omp configuration.
- Its `models` selects `anthropic-messages` for Claude and `openai-responses` for GPT. Automatic model discovery is disabled.
- `~/.omp/agent/config.yml` sets `modelRoles.default` to `cliproxy/gpt-6.1-sol`.
- `enabledModels` contains the five CLIProxy selectors below, two OpenCode Go selectors, and Glyph Cluster Free from Command Code.
- `disabledProviders` excludes the other installed providers, including local engines.

The CLIProxy models are:

- `claude-sonnet-5-5`
- `claude-opus-5-5`
- `claude-haiku-5-5`
- `gpt-6.1-sol`
- `gpt-6-luna`

OpenCode Go uses its existing omp credential. On a new machine, run `omp login opencode-go` to supply its API key.

The other enabled chat models are:

- `opencode-go/glm-5.3-flash`
- `opencode-go/deepseek-v4.1-flash`
- `commandcode/stealth/glyph-cluster:free`

Command Code uses its existing omp credential. On a new machine, run `omp login commandcode` to supply its API key.

`enabledProviders` controls external configuration discovery, not model availability. Do not use it as a model allowlist.

To change the CLIProxy list, update both `models.yml` and `enabledModels`. After an omp update, add new providers to `disabledProviders`.
Project configuration arrays replace global arrays. A project that sets `disabledProviders` or `enabledModels` must include the complete restriction.

Refresh the model catalog and verify the providers:

```sh
omp models refresh cliproxy
omp models --json --kind all
omp --print --no-session --no-tools --no-title --thinking low 'Reply with exactly: CLIPROXY_OK'
omp --print --no-session --no-tools --no-title --model opencode-go/glm-5.3-flash --thinking low 'Reply with exactly: OPENCODE_GO_OK'
omp --print --no-session --no-tools --no-title --model opencode-go/deepseek-v4.1-flash --thinking low 'Reply with exactly: DEEPSEEK_OK'
omp --print --no-session --no-tools --no-title --model commandcode/stealth/glyph-cluster:free --thinking off 'Reply with exactly: GLYPH_OK'
```

The available providers must be `cliproxy`, `opencode-go`, and `commandcode`. The chat model scope must contain the eight selectors above.
Start a new omp session to use the default model.

