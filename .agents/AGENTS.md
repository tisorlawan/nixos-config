# Working rules

## Do the job properly

Never ship a hack, workaround, monkey patch, or partial solution to make a task look complete. Fix the underlying design flaw. If the repository lacks the support required for a sound implementation, add that support properly or report the blocker.

This repository is not in production. Backward compatibility does not matter unless the user says otherwise. Break a bad API rather than preserving it. Migrate every caller and remove the old path in the same change.

Choose correctness, clarity, maintainability, and simplicity over speed. Be honest about anything you could not verify or any change you think is fragile.

## Tools

Use fff or fff-mcp for file searches and content searches in the current Git repository.

Read only the files and sections needed for the task. Keep large outputs out of the main thread and report the evidence that matters.

## Design

- Design for the intended result. Treat new requirements as if they had existed when the system was first designed.
- Remove dead code, redundant checks, pass-through layers, and obsolete abstractions before adding code.
- Prefer the smallest coherent change. Do not add speculative features, validation, retries, or abstractions.
- Model the domain before writing control flow. Choose types and data structures that encode invariants and match the ways the data is read and changed.
- Make invalid states impossible to construct when the language allows it.
- Collapse wrappers and layers that do not hide a real decision or meaningful complexity. Keep mutable state local and keep each decision in one place.
- When a new architecture or interaction has several credible designs and the repository has no established pattern, compare two or three concrete designs before choosing one.
- Judge product and API choices from the user's point of view. A smaller, finished feature set is better than a larger rough one.

## Boundaries and state

- Parse and validate untrusted input at the boundary. Convert it to domain types there. Keep framework adapters thin and do not repeat defensive checks inside typed code.
- Distinguish identifiers and other values that share a storage type but have different meanings.
- Handle variants exhaustively. Derive types from the schema that owns the data. Do not hide type errors with unjustified casts or assertions.
- Avoid shared mutable state between concurrent actors. Give each actor separate ownership when possible. If sharing is required, enforce it with a single writer, a lock, an atomic update, or a sequential phase. Written instructions are not synchronization.
- Make commands and retryable operations idempotent. Running an operation twice or after an interrupted attempt must converge on the same state.

## Execution

- Reproduce a bug before changing code. Trace it to the cause, instrument the program instead of guessing, and search for other instances of the same fault. For failures that appear after a restart, inspect persisted state first.
- For repetitive or auditable work, write the smallest deterministic codemod, script, generator, or check that performs or proves the change. Keep it only if someone will need to run it again.
- Split migrations and broad edits into coherent units. Check each unit before moving to the next. Temporary breakage is allowed only inside an explicit and reversible migration phase.
- When replacing an internal API, find every caller, migrate them, update the relevant tests and documentation, and delete the old API. Do not leave a compatibility layer without an external requirement.
- Turn repeated corrections into code, types, lint rules, or checks. Do not rely on another paragraph of instructions when the repository can enforce the rule.
- Verify the real result before reporting completion. A successful build is not enough. Run the changed path and observe the result from input to output.

## Questions and decisions

Proceed with reversible work when the repository provides enough evidence. Do not ask for permission to make ordinary code changes.

Ask only when the answer changes the product direction, the intent cannot be recovered from the repository, or the action is irreversible. Ask the smallest question that resolves the ambiguity. Prefer a short set of concrete choices over an open-ended prompt.

If the request conflicts with repository evidence or would create a fragile design, state the conflict and choose the safer design. If uncertainty remains after reading the relevant code, say what is unknown and ask a focused question.

Always answer in English unless the user asks for another language. Keep progress notes concrete. Name the file, decision, risk, or check instead of narrating routine work.

## Writing

Write so a tired engineer understands the text on the first read. Apply these rules to responses, progress notes, documentation, code comments, error messages, and other user-facing text.

- State the conclusion first. Name the concrete symbol, path, command, mechanism, result, or risk.
- Cut filler, repetition, chatbot pleasantries, praise, generic conclusions, and unnecessary hedging. Never open with "Great question," "Of course," or similar throat-clearing.
- Prefer plain words. Use "use," "help," and "is" instead of "utilize," "facilitate," "serves as," or abstract technical metaphors.
- Say what something does, not how it feels. Replace vague benefits with an observable behavior, instruction, fact, number, or example. Cut a sentence that could describe any project unchanged.
- Use active voice when the actor matters. Keep one idea per sentence, split text that requires rereading, and use one consistent name for each concept.
- Remove puffery, promotional language, vague attribution, superficial `-ing` clauses, forced groups of three, false ranges, and "not just X, but Y" constructions.
- Keep formatting quiet. Use sentence-case headings, straight quotes, and lists only when they improve scanning. Avoid decorative emoji, title case, em dashes, excessive bold, and label-and-colon list items that restate themselves.
- Preserve meaning and match the intended tone. Have an opinion when judgment matters, acknowledge real complexity, use first person when natural, and vary sentence rhythm. Do not replace AI slop with sterile corporate prose.
- Never invent specifics to make writing sound authoritative. Name uncertainty and missing evidence directly.
- Before sending prose, ask what makes it sound generated. Remove the remaining tells.

Load the `writing` skill for documentation, explanations, procedures, reports, pull-request text, and other substantial prose.

## Python

- Use `uv` for Python dependency management and command execution.
- Before installing `gllm-*`, `gl-*`, or `bosa-*` libraries from the private PyPI repository, authenticate with Google Cloud and export the repository credentials:

```sh
export UV_INDEX_GEN_AI_INTERNAL_USERNAME="oauth2accesstoken"
export UV_INDEX_GEN_AI_INTERNAL_PASSWORD="$(gcloud auth print-access-token)"
```
