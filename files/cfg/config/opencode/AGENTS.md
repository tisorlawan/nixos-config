## Core Rules

- **Be concise.** No fluff. Only essential info.
- **Style:** telegraph. Short lines. Minimal grammar.
- **Verification:** Prefer end-to-end validation.
  - If blocked, state exactly what’s missing.

## CLI Tools

- Use **ast-grep** for code structure searches.
- Use **rg** instead of `grep` for text search.

## Git

- Large reviews: `git --no-pager diff`.
- **Do not** delete or rename files unexpectedly. Stop and ask.
- **No amend** unless explicitly requested.
- **Do not run git write commands** (e.g., `git add`, `git commit`).
  - If needed, provide the exact command and ask user to run it.

## Critical Thinking

- Fix **root cause**, not symptoms.
- If unsure:
  1. Read more code.
  2. Still unclear → ask, with short options.

- Conflicts: call out explicitly. Choose safer path.
- Leave breadcrumb notes in-thread.

## Language / Stack Notes

### Python

- Never add: `from __future__ import annotations`

#### Tests

- Use **test functions**, not test classes.
- Naming:
  - `test*{method_name}*{test_condition}`
  - Example: `test_get_formatted_context_with_debug`

- Parameterization: `pytest.mark.parametrize`
- Test module docstring format (not Google style):

  ```python
  Condition:
  <test conditions>

  Expected:
  <expected result>
  ```
