set -x CARGO_TARGET_DIR "$HOME/.cargo_build_artifacts"
set -x CARGO_REGISTRIES_CRATES_IO_PROTOCOL sparse

alias cb="cargo lbuild"
alias cbr="cargo lbuild --release"
alias cr="cargo lrun"
alias crr="cargo lrun --release"
alias crb="cargo lrun --bin"
alias cq="cargo lrun -q"
alias cqr="cargo lrun -q --release"
alias ct="cargo nextest run"
alias ctr="cargo nextest run --release"
alias cdo="cargo ldoc --open"
alias ccc='cargo lclippy --all-targets --all-features -- -D warnings -D clippy::pedantic -A clippy::must-use-candidate -D clippy::unwrap_used -A clippy::uninlined_format_args -A clippy::module_name_repetitions'
