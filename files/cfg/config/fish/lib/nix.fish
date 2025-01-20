alias nix-generations-ls="nix profile history --profile /nix/var/nix/profiles/system"
alias nix-generations-rm="sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than"
alias ns="nix-shell --run fish"
alias ds="devenv shell fish"
alias fs="nix develop --command fish"

# if test -e ~/.config/fish/functions/auto-nix-shell.fish
#     . ~/.config/fish/functions/auto-nix-shell.fish
# end
