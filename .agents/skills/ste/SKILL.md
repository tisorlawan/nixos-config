---
name: ste
description: "Answer in a relaxed form of ASD-STE100 (Simplified Technical English), about 80% of the spec. Explicit invocation only. /ste <request> does the request and writes the reply in STE style. /ste with no argument rewrites the last reply."
disable-model-invocation: true
---

# STE

Write in about 80% of ASD-STE100. Short sentences, one meaning per word, and no guesswork for the reader.

## Modes

- **`/ste <request>`: do your work and answer in ste style above.
- **`/ste` with no argument:** Rewrite your last reply, the one before the `/ste` message. Output only the rewritten text. Do not add a preface, a summary of changes, or an offer to do more. If the reply already follows the rules, say so in one line.
- **`/ste` with an explicit rewrite instruction:** When the argument tells you to rewrite something ("rewrite README.md", "rewrite this: ..."), rewrite that target. Edit a file in place. Return pasted text rewritten.

Never rewrite unless the user asks for a rewrite. A question such as "what does this repo do" is a request, so answer it.

The style covers the prose you write to the user. It does not change code, commands, identifiers, file paths, numbers, quotations, or exact error strings. It does not change the facts. Do not add a fact, and do not delete one to shorten a sentence.
