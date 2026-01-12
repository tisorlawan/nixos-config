#!/usr/bin/env bash

uv run --with argon2-cffi --with cryptography python3 - "$@" << 'EOF'
import sys
from argon2.low_level import hash_secret_raw, Type
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import getpass
from pathlib import Path

path = sys.argv[1] if len(sys.argv) > 1 else Path(__file__).parent / "passlock.enc"
with open(path, "rb") as f:
    data = f.read()

salt, nonce, ciphertext = data[:16], data[16:28], data[28:]
password = getpass.getpass("Master password: ").encode()

key = hash_secret_raw(password, salt, time_cost=2, memory_cost=19456,
                      parallelism=1, hash_len=32, type=Type.ID)

plaintext = AESGCM(key).decrypt(nonce, ciphertext, None)
print(plaintext.decode())
EOF
