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

Write so a tired engineer understands the text on the first read. Every sentence must carry a fact, decision, instruction, risk, or useful opinion. Apply this guidance to responses, progress notes, documentation, code comments, error messages, and other user-facing text.

Accuracy and meaning come first, then clarity, then brevity. Follow the user's requested format and the document's conventions. Preserve exact quotations and technical identifiers. If a rule makes a sentence awkward, rewrite the sentence without changing its meaning or dropping a necessary caveat.

### Write for the reader's task

- Start with what the reader needs to know or do. State the answer, decision, result, or blocking condition before the background. Follow it with evidence, constraints, and the next action.
- Include enough context to act safely. Explain unfamiliar concepts when needed, but do not teach what the reader already knows.
- Give each paragraph one purpose. Put the common path before alternatives and exceptions.
- Name the concrete symbol, path, command, mechanism, or risk. Replace general claims with observable behavior. For example, "`save()` catches `OSError` and returns `False`, so callers cannot distinguish a full disk from a missing directory" explains more than "`save()` has poor error handling."
- When judgment matters, recommend an option and explain the decisive constraint or tradeoff. Do not substitute an unranked list of pros and cons for a decision.
- Stop when the reader has the answer and any necessary next action. Do not repeat the answer in a generic conclusion.

### Use direct, natural language

- Prefer short, ordinary words. Write "to," not "in order to," and "because," not "due to the fact that." Keep technical terms when they are more precise.
- Use "use," not "utilize" or "leverage." Use "help," not "facilitate." Prefer "is" and "has" to elaborate substitutes.
- Cut repetition, promotional claims, empty praise, unnecessary hedging, and formulaic transitions. Delete throat-clearing such as "Great question," "Of course," "It is important to note," and "I hope this helps."
- Say what something does, not how impressive it is. Do not call a procedure "easy," "simple," or "quick."
- Replace vague attribution such as "experts believe" with a named source or remove the claim.
- Remove stock constructions: forced groups of three, false ranges, "not just X, but Y," and superficial clauses about "highlighting," "ensuring," or "showcasing" something. Do not rotate through synonyms for the same concept.
- Do not invent technical-sounding metaphors. Name the mechanism. Write "a parameter worth varying," not "a dial worth turning." Write "this still matters," not "this earns its keep." When a literal phrase is available, use it.
- Preserve the author's meaning and intended tone when revising. Keep established terminology unless it is wrong. Do not strengthen a claim to make it sound decisive or erase the author's voice to satisfy a style preference.
- Vary sentence length. Use first person when natural. Concision should not produce fragments that require rereading or prose that sounds mechanically uniform.

### Remove ambiguity

- Put one thought or instruction in each sentence.
- Split instructions longer than about 20 words and other sentences longer than about 25 words when the split improves clarity.
- Use active voice when the actor matters. Write "the compiler checks the query," not "the query is checked." Passive voice is useful when the actor is unknown or irrelevant.
- Put a condition before the instruction it controls. Keep "only," "not," and other modifiers next to the words they modify.
- Give every pronoun one obvious referent. Repeat the noun when needed. Avoid "this" or "which" when either points to an entire preceding clause. Name the fact or result instead.
- Use one name for each concept. Break up long noun strings, and keep articles and verbs that make the grammar clear.
- Give every clause a verb. Do not write "Phase 1 moves the parser and Phase 2 the runtime."
- Repeat articles when they distinguish separate things: "the client and the host."
- State alternatives explicitly instead of using `and/or` or unexplained slashes. Make clear which items `and` or `or` joins. Use `both...and`, `either...or`, or separate sentences when grouping is ambiguous.
- Use present tense for current behavior. Use "will" only for events that happen later.

### Choose a structure that fits

Do not turn every answer into a document. Keep each document focused on one job. Split and link when a document needs another job. Choose the structure that serves the reader:

- Tutorial: teach through a concrete task. State what the reader will build, give an early visible result, and make every step produce another observable result. Keep explanations short and link to deeper material.
- How-to guide: help a competent reader reach a goal. Give prerequisites, direct steps, and a way to check success. Skip background, teaching, and completeness for its own sake. Put optional paths after the common path.
- Reference: organize facts for lookup, following the system it describes. Cover accepted values, defaults, limits, errors, and observable behavior. Generate repetitive reference data from its source when possible. Keep reference material factual. Save opinions and tradeoffs for explanations and proposals.
- Explanation: build a mental model of one bounded topic. Cover the reasons, constraints, alternatives, and tradeoffs. Explain what the design does and why it won over the credible alternatives.
- Change report or pull request: state what changed and why, then the checks performed and any remaining risk. Distinguish completed work from proposed work. Omit the investigation log unless it changes a decision.

For code and architecture explanations, give the reader a working mental model instead of annotated source code:

1. State what the subsystem does and why it exists.
2. Define only the concepts needed to follow the flow.
3. Trace one concrete path from trigger to result, including data movement and decision points.
4. Name the files and symbols that own each decision.
5. End with non-obvious constraints, failure modes, and likely misconceptions.

Do not list every file, type, or function. Include only what the reader needs to answer the question or begin changing the subsystem.

Keep the main purpose clear. Link to supporting reference material rather than interrupting a procedure with a reference dump.

### Make instructions and errors actionable

- Write procedural steps as commands, in execution order. Do not narrate an operation in the passive voice. Put prerequisites, conditions, and warnings before the affected step.
- Show commands the reader can run. Identify placeholders and the required working directory or environment when they matter.
- State the expected result after important steps and how to check it. Explain relevant failure cases without burying the common path.
- For an error, say what failed and why, if known. Give a next action only when it can help. Do not invent a cause or suggest a retry without evidence.

### Keep formatting quiet

- Use sentence-case headings that name the point or task. Use one top-level heading and do not skip heading levels.
- Use numbered lists for ordered steps and bullets for unordered items. Introduce a list with a complete sentence and keep its items parallel.
- Use a table only when comparing the same attributes across items helps the reader.
- Prefer prose to a list of labels that merely restate each item. Avoid unnecessary headings.
- Do not bold every label. Use bold for interface elements or when the document convention requires it.
- Use straight quotes. Do not add decorative emoji.
- Avoid em dashes and semicolons. Start a new sentence instead.
- Use parentheses only when the text forms a complete grammatical unit.
- Use colons to introduce lists, examples, or definitions. Do not use them as decorative connectors.
- Put code, paths, flags, and symbols in code font. Use link text that names the destination, not "click here."

### Keep comments useful

Prefer code, types, schemas, tests, and lint rules over comments that compensate for unclear or unenforced behavior.

- Explain non-obvious invariants, external constraints, deliberate tradeoffs, or why the obvious implementation is wrong. Do not narrate the next line or restate a symbol's name.
- Name the source of an external constraint. Link to the specification, issue, or upstream bug when available.
- Replace "do not remove" warnings with an enforced constraint when the repository can express one.
- Update or delete a comment in the same change that invalidates it. Remove comments about dead code, obvious control flow, and temporary implementation history.

### Support technical claims

- Check symbols, paths, options, commands, and counts against the current source. Give the regeneration command for generated counts or trees.
- Separate observation from inference. Mark an inference when the evidence does not directly prove the claim. State what remains unknown and what evidence would resolve it, rather than hiding uncertainty behind a hedge.
- Cite the evidence that supports the claim: a symbol, `file:line`, command result, trace, screenshot, issue, or specification. Do not invent details or sources to sound authoritative.
- Report the exact scope of verification. A successful build does not prove runtime behavior. Include failed or inconclusive checks when they affect confidence or the next action.

### Review before sending

Read awkward sentences aloud and rewrite them. Before sending or committing prose, check it once:

1. Does the opening state what the reader needs to know or do?
2. Can any sentence lose words without losing meaning?
3. Does each instruction have one action and any condition in front?
4. Can any sentence be read two ways?
5. Does each concept keep one name?
6. Are the symbols, paths, commands, and claims verified?
7. Does the text sound like a person with evidence and a point of view?

If a rule makes the writing worse, rewrite the sentence another way. The rules serve the reader. A sentence that follows every rule and still sounds machine-written has failed.

## Python

- Use `uv` for Python dependency management and command execution.
- Before installing `gllm-*`, `gl-*`, or `bosa-*` libraries from the private PyPI repository, authenticate with Google Cloud and export the repository credentials:

```sh
export UV_INDEX_GEN_AI_INTERNAL_USERNAME="oauth2accesstoken"
export UV_INDEX_GEN_AI_INTERNAL_PASSWORD="$(gcloud auth print-access-token)"
```
