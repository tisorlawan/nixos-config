#!/usr/bin/env python3
"""Render data.json into a self-contained stats.html.

The template holds a `__DATA__` placeholder that gets replaced with the JSON
document, so the output page needs no server and no network. Open it with
`file://` or serve the directory with any static server.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "data",
        nargs="?",
        type=Path,
        default=HERE / "data.json",
        help="JSON produced by collect.py (default: ./data.json)",
    )
    parser.add_argument(
        "-t",
        "--template",
        type=Path,
        default=HERE / "template.html",
        help="HTML template (default: ./template.html)",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=HERE / "stats.html",
        help="HTML to write (default: ./stats.html)",
    )
    args = parser.parse_args()

    if not args.data.is_file():
        print(f"error: {args.data} not found. Run collect.py first.", file=sys.stderr)
        return 1
    if not args.template.is_file():
        print(f"error: {args.template} not found.", file=sys.stderr)
        return 1

    # Validate before embedding so a malformed document fails here rather than
    # as a silent JavaScript error in the browser.
    document = json.loads(args.data.read_text(encoding="utf-8"))
    for key in ("rows", "timezone", "generated_at", "homes"):
        if key not in document:
            print(f"error: {args.data} is missing '{key}'", file=sys.stderr)
            return 1

    template = args.template.read_text(encoding="utf-8")
    if "__DATA__" not in template:
        print(f"error: {args.template} has no __DATA__ placeholder", file=sys.stderr)
        return 1

    # `</script>` inside a JSON string would close the tag early. Escaping the
    # slash keeps the document valid without changing parsed values.
    payload = json.dumps(document).replace("</", "<\\/")
    args.output.write_text(template.replace("__DATA__", payload), encoding="utf-8")

    print(f"wrote {args.output} ({len(document['rows'])} rows)", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
