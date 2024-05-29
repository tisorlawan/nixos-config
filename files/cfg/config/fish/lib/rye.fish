set -Ua fish_user_paths "$HOME/.rye/shims"
set -x UV_HTTP_TIMEOUT 3600

if type -q rye
    alias rr="rye run"
end
