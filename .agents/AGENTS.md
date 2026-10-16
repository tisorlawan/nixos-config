# Working rules

- For file searches and grep in the current repository, use the fff MCP tools first.
- Use `find_files` for paths, `grep` for file contents, and `multi_grep` for multiple identifiers in one call.
- Read the relevant files after the search. Check exact matches before you use fuzzy results as evidence.
- If fff is unavailable or the search needs files outside its index, use `rg` or `rg --files`.

Start each task by restating my goal and the problem I am solving in your own words.
For writing, use simplified-technical-english skill.

## Quality

- Say what you could not verify and which changes are fragile.
- Prefer correctness, clarity, maintainability, and simplicity over speed.
- Do not ship hacks, workarounds, monkey patches, or partial solutions. Fix the underlying design flaw. If the repository lacks the support a sound fix needs, add it or report the blocker.
- This repository is not in production. Backward compatibility does not matter unless I say so. Break a bad API instead of preserving it.

## Approvals

Keep going when a step does not need my input, and put status notes in the same message as the next action. Stop and ask only when you cannot continue without me, or before anything destructive: deleting data, force-pushing, or changing anything outside this repository.

## Questions

Make ordinary reversible changes without asking. Ask only when the answer changes product direction, the intent is not recoverable from the repository, or the action is irreversible. Ask the smallest question, with concrete choices when possible.

If a request conflicts with repository evidence or would create a fragile design, state the conflict and choose the safer design.

## Design

- Design for the intended result. Treat new requirements as if they existed from the start.
- Delete dead code, redundant checks, pass-through layers, and obsolete abstractions before adding code.
- Make the smallest coherent change. No speculative features, validation, retries, or abstractions.
- Model the domain first. Pick types that encode invariants and make invalid states unrepresentable.
- Keep mutable state local and each decision in one place.
- When several designs are credible and the repository has no pattern, compare two or three before choosing.
- Judge product and API choices from the user's view. A small finished feature set beats a large rough one.

## Boundaries and state

- Parse untrusted input at the boundary into domain types. Keep adapters thin and do not repeat defensive checks inside typed code.
- Keep distinct types for identifiers that share a storage type.
- Handle variants exhaustively. Derive types from the schema that owns the data. Do not hide type errors with casts or assertions.
- Avoid shared mutable state between concurrent actors. Give each actor its own state, or enforce sharing with a single writer, lock, atomic update, or sequential phase.
- Make commands and retryable operations idempotent.

## Execution

- Reproduce a bug before changing code. Trace it to the cause with instrumentation, and search for other instances of the same fault. For failures after a restart, inspect persisted state first.
- For repetitive or auditable work, write a small deterministic script or check. Keep it only if it will be run again.
- Split broad edits into coherent units and check each before the next. Temporary breakage is allowed only in an explicit, reversible migration phase.
- When replacing an internal API, migrate every caller, update tests and docs, and delete the old API.
- Turn repeated corrections into code, types, lint rules, or checks.
- Before reporting completion, run the changed path and observe the result. A passing build is not enough.

## Python

- Use `uv` for dependencies and command execution.
- Before installing `gllm-*`, `gl-*`, or `bosa-*` from the private PyPI repository, export credentials:

```sh
export UV_INDEX_GEN_AI_INTERNAL_USERNAME="oauth2accesstoken"
export UV_INDEX_GEN_AI_INTERNAL_PASSWORD="$(gcloud auth print-access-token)"
```
