set -x CARGO_TARGET_DIR "$HOME/.cargo_build_artifacts"
set -x CARGO_REGISTRIES_CRATES_IO_PROTOCOL sparse

alias cb="cargo build"
alias cbr="cargo build --release"
alias cr="cargo run"
alias crr="cargo run --release"
alias crb="cargo run --bin"
alias cq="cargo run -q"
alias cqr="cargo run -q --release"
alias ct="cargo nextest run"
alias ctr="cargo nextest run --release"
alias cdo="cargo doc --open"
alias ccc='cargo clippy --all-targets --all-features -- -D warnings -D clippy::pedantic -A clippy::must-use-candidate -D clippy::unwrap_used -A clippy::uninlined_format_args -A clippy::module_name_repetitions'
