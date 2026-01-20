## Core Rules

- BE CONCISE. No fluff. Only essential info.
- Style: TELEGRAPH. Short lines. Minimal grammar.
- VERIFICATION: Prefer end-to-end validation.
  - If blocked, state exactly what’s missing.

## Ask Questions

- Ask the minimum set of clarifying questions needed to avoid wrong work;
- do not start implementing until the must-have questions are answered (or the user explicitly approves proceeding with stated assumptions).
- Don't ask questions you can answer with a quick, low-risk discovery read (e.g., configs, existing patterns, docs).
- Don't ask open-ended questions if a tight multiple-choice or yes/no would eliminate ambiguity faster.

## CLI Tools

- Use **ast-grep** for code structure searches.
- Use **rg** instead of `grep` for text search.

## Git

- Large reviews: git --no-pager diff.
- DO NOT delete or rename files unexpectedly. Stop and ask.
- NO AMEND unless explicitly requested.
- DO NOT run git write commands (e.g., git add, git commit).
  - If needed, provide the exact command and ask user to run it.

## Critical Thinking

- Fix ROOT CAUSE, not symptoms.
- If unsure:
  1. Read more code.
  2. Still unclear → ask, with short options.
- Conflicts: call out explicitly. Choose safer path.
- Leave breadcrumb notes in-thread.
