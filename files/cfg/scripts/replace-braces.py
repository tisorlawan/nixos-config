#!/usr/bin/env python3
import re
import sys


def process_text(text):
    """
    Replaces truly single '{' with '{{' and '}' with '}}'.
    Uses negative lookbehind and lookahead to ensure braces are not
    already part of a pair.
    """
    # Pattern: A '{' not preceded by '{' AND not followed by '{'
    text = re.sub(r"(?<!{){(?!{)", "{{", text)

    # Pattern: A '}' not preceded by '}' AND not followed by '}'
    text = re.sub(r"(?<!})}(?!})", "}}", text)

    return text


if __name__ == "__main__":
    input_text = sys.stdin.read()
    output_text = process_text(input_text)
    sys.stdout.write(output_text)
