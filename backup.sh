#!/bin/sh
set -eu
umask 077

restore_dir=$(mktemp -d)
trap 'rm -rf "$restore_dir"' EXIT HUP INT TERM

# Keep the encrypted payload off stdin so GnuPG can use stdin for its
# passphrase prompt when pinentry runs in loopback mode.
encrypted_archive="$restore_dir/backup.asc"
cat >"$encrypted_archive" <<'EOF'
-----BEGIN PGP MESSAGE-----

jA0ECQMKGH7tfEK7Vdb/0uoBqGLCOkH1p7HSJwnY2ilt4Ku4gGuqm6PKkDnscjps
q6SyCQ6vqeE36A+ztEyY8oi9KfMt8hyI0SZo+TISAT7QT3yhJMiQrMZGSsJtHiIM
P/eRqvkGrzKk4fexEQ9q0NECo9kVX1PRyiCsrDKznyqYuMAFHIsFMeUANGA1Lyxf
2pI6uaC2q5L2/yU04EvafY/zMKldAwRAknfWXCEJbzGIa/2N7hUvum53vYkScViI
nq7mVZlwZzgqbqrycBtMS2zsU+SWg41rRYsynsJGKLUEwsSa2wRKAY5zW9oMEgrA
IBL7r+vz8h5cJcKdt0DBQ54oAL9FfgojsOZ41r2Vax1Q0FUou+S/IG3RV9C5LdTW
yZpQoNtb8roZsS3QB0vk9swG7wPOeqPPZ1SIA8MVftMeyVzNQmkdd7sV8h71n8Ic
zEGPPmUWZM4kf2h7joKFRWHWGtTBHBEMcS2H8NlRO287GZquqQWZsT+ULvL7Nep5
0uCsTYRU8Ozbu4uEd/Odhfw6SLo+4Fdq3kDhDhl64dAeMdEU8db1flGE9/VWMODe
0MXfYAzAcJscUc/knZhQKjlhNuT0Q+ZjNahuvQpqXK1bLVOk1o81kqzzaQDqo5k1
aHNwFlXCUHG6Trp+lKL++sFD/mZZqmVEaxHS/NgdE5xjCKKY6YH7Z40CGQSxD4yG
EYhR6cufEkXBP4lx65F8ju0ATWBUTScbppa56ThDPr5y/GG6YAy3plPcBmobxTCz
40EIkj1V+Ez423wJAag8d27pCE8gyrgmBpiJB/x+q3cB8CXc3/zQCsdfAWR3nUwT
2GBSAHtnFlC8POfq6Hvt4G8nP40jg2dOo9qwaHxOrQyyV0BcHHnOjgEUc6Wb47bx
MVyyMqemcvMMOn/swnNVEwUxeeQRxhUoky6tkKu8tA3++t9gOhT5gBXxlQmQ2h1c
Aq+vxV1aIWHWz4xHLuUwFaqH2AHdAI0Yw9npLxSQQUytxjfqzL9jdZooqRZqyH5F
EAuDBo0scykYvuLwwq/LoSlLTkN8RszBolsU6zhqaP5rXB5KFeHioLuM8O2RFmOa
77uWD2On+7ZbVj6Crnr5taza3j/is5dR4UoTwEUMy5kzp6D4rRqON260pPUE4PtH
cz/QL8cz85wmhlro59r3eBf73Ts05GHYAl6iylLNvO8z7GoA1pFZDNwgpvY58nRG
cO+2Zx2WIbtI8KFfBd0AFjxrafcFMmTbcI+PPAC0ZB8DTW1/tdBrq+r/40NcJzs3
iVyEfIruyZkPL9lRqzo5dvcYoopzvl5vEEBGxPA9dqW8HSV9vWs/3FTLih/sG3n2
6IIhPdrbL1tVQGUlKuYqIur89ucLDmw2Z0Iv1Lz1GmGFdXAClPVVV9VnNeI/pN+w
UxLiY75i/2/saZSNUbo5bT8HXNCVN1GiEuCsFBimf/fulLikW1Cdr+7QgYkG1zly
X/rQbF3OrM1IoddCSF/CCWxsQekN1dEjotmRuGnJbBRx9H4s2p0TCWHs/K+O4F8V
MHRyny1wLQ==
=U6Pz
-----END PGP MESSAGE-----
EOF

# The default pinentry agent cannot always open a TTY in tmux/SSH sessions and
# otherwise reports "Inappropriate ioctl for device".
gpg --pinentry-mode loopback --decrypt "$encrypted_archive" |
    tar -xzf - -C "$restore_dir"

gpg --import "$restore_dir/tisorlawan-private.asc"
gpg --import-ownertrust "$restore_dir/ownertrust.txt"

echo
echo 'Try running: gpg --list-secret-keys --keyid-format LONG'
