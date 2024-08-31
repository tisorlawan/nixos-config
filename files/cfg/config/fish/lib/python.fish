set -x PYTHONDONTWRITEBYTECODE 1
set -x _TYPER_STANDARD_TRACEBACK 1

alias p="python"
alias a="source .venv/bin/activate.fish"
alias d="deactivate"

function py_prefix
    python -c "import sys; print(sys.prefix)"
end

uv generate-shell-completion fish | source
