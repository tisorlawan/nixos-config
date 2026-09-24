curl -fsSL https://chatgpt.com/codex/install.sh | sh
curl -fsSL https://claude.ai/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/router-for-me/cliproxyapi-installer/refs/heads/master/cliproxyapi-installer | bash
rm -rf ~/cliproxyapi/config.yaml
ln -srf ./files/cfg/cli-proxy-api/config.yaml ~/cliproxyapi/config.yaml
systemctl --user restart cliproxyapi.service

mkdir -p ~/.config/codex-cpa && cat > ~/.config/codex-cpa/config.toml <<'EOF'
# Codex home for the T3 Code instance that routes through CLIProxyAPI.
# T3 sets CODEX_HOME to this directory (Settings > Providers > Codex > CODEX_HOME path)
# and passes CPA_API_KEY as an instance Variable.
model = "gpt-6.1-sol"
model_provider = "cpa"

[model_providers.cpa]
name = "CLI Proxy API"
base_url = "http://127.0.0.1:8317/v1"
wire_api = "responses"
env_key = "CPA_API_KEY"
requires_openai_auth = false
EOF


# Claude Config
    ANTHROPIC_BASE_URL http://127.0.0.1:8317
    ANTHROPIC_AUTH_TOKEN sk-xhnUCHMoOnugGo9W3ahTpfahUTaPCmrCLZB5UNdgLKkkx
    ANTHROPIC_MODEL claude-opus-5-5
