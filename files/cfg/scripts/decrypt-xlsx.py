#!/usr/bin/env python
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "msoffcrypto-tool",
# ]
# ///


import sys
from pathlib import Path

import msoffcrypto


def main():
    if len(sys.argv) < 3:
        print("Please add encrypted xlsx file and password", file=sys.stderr)
        sys.exit(1)
    password = sys.argv[2]

    input_path = Path(sys.argv[1])
    output_path = input_path.with_stem(input_path.stem + "_decrypted")
    encrypted = open(str(input_path), "rb")
    file = msoffcrypto.OfficeFile(encrypted)

    file.load_key(password=password)

    with open(output_path.name, "wb") as f:
        file.decrypt(f)
        print(f"Saved: {output_path}")

    encrypted.close()


if __name__ == "__main__":
    main()
