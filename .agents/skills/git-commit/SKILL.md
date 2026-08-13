---
name: git-commit
description: "Write a repository-style commit message from staged changes. Use when asked for a commit message or a squash message from a base commit."
---

# Git Commit

1. Inspect only staged changes with `git diff --cached`. If the invocation includes a base commit, inspect `git diff <base> --cached` instead.
2. If the diff is empty, report that there are no staged changes and stop.
3. Inspect the latest 20 commits with `git log -n 20` to learn the repository's message style.
4. Write a concise commit message that follows the observed conventions and accurately covers the full diff. Add a body only when it provides useful context.
5. Output only the raw commit message, without commentary or a Markdown code block.

Do not stage files, create a commit, or modify the working tree.
