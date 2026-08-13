---
name: writing
description: "Write or revise substantial prose, including documentation, code comments, explanations, procedures, reports, and pull-request text."
---

# Writing

Write so a tired engineer understands the text on the first read. Every sentence must carry a fact, decision, instruction, risk, or useful opinion.

## Start with the reader

Decide what the reader needs to do or understand. Write for that need, not to display coverage.

- Use the real symbol, file, flag, command, or product name from the repository.
- State the conclusion first. Follow it with evidence, constraints, and the next action.
- Be specific. Write "a column rename fails the build," not "schema changes can cause issues."
- Have an opinion when judgment matters. Do not hide behind a neutral list of advantages and disadvantages.
- Keep reference material factual. Save opinions and tradeoffs for explanations and proposals.

## Cut the slop

Delete any word that does no work. Prefer the short, ordinary word.

- "To," not "in order to."
- "Because," not "due to the fact that."
- "Use," not "utilize" or "leverage."
- "Help," not "facilitate."
- Delete "it is important to note," "of course," and "I hope this helps."
- Replace vague claims such as "experts believe" with a named source or remove them.
- Remove puffery, promotional language, generic conclusions, and formulaic transitions.
- Do not call something "easy," "simple," or "quick" in instructions.
- Do not invent technical-sounding metaphors. Name the mechanism. Write "base," "method," "limit," or "last phase" instead of "substrate," "vector," "ratchet," or "endgame."

Avoid stock AI constructions:

- Forced groups of three
- "Not just X, but Y"
- Superficial clauses that start with "highlighting," "ensuring," or "showcasing"
- Synonym cycling for the same concept
- Fancy substitutes for "is" and "has"
- Excessive hedging
- Empty acknowledgements and praise

## Make sentences easy to parse

- Put one thought or instruction in each sentence.
- Split instructions longer than about 20 words and other sentences longer than about 25 words when the split improves clarity.
- Mix sentence lengths. A page of equally short sentences sounds mechanical.
- Use active voice when the actor matters. Write "the compiler checks the query," not "the query is checked."
- Put a condition before the instruction it controls.
- Keep "only," "not," and similar modifiers next to the words they change.
- Give every pronoun one obvious referent. Repeat the noun when needed.
- Use one name for each concept. Do not rotate through synonyms.
- Break up long noun strings.
- Keep articles and verbs when removing them would create a second reading.
- Use present tense. Use "will" only for events that happen later.
- Read awkward sentences aloud and rewrite them.

## Remove structural ambiguity

- Give every clause a verb. Do not write "Phase 1 moves the parser and Phase 2 the runtime."
- Avoid `and/or` and unexplained slashes. Write the exact alternatives.
- Make clear which items `and` or `or` joins. Use `both...and`, `either...or`, or separate sentences when grouping is ambiguous.
- Repeat articles when they distinguish separate things: "the client and the host."
- Avoid `this` or `which` when either points to an entire preceding clause. Name the fact or result instead.
- Keep words that make the grammar unambiguous. Clarity matters more than the shortest possible sentence.

## Keep formatting quiet

- Use sentence-case headings.
- Use headings that state the point or task, not a vague topic.
- Use one top-level heading and do not skip heading levels.
- Avoid em dashes and semicolons. Start a new sentence instead.
- Use parentheses only when the text forms a complete grammatical unit.
- Use colons to introduce lists, examples, or definitions. Do not use them as decorative connectors.
- Do not bold every label. Use bold for interface elements or when the document convention requires it.
- Use numbered lists for sequences and bullets for unordered items.
- Introduce a list with a complete sentence and keep its items parallel.
- Use straight quotes. Do not add decorative emoji.
- Put code, paths, flags, and symbols in code font.
- Use link text that names the destination. Never write "click here."

## Pick the document type

Keep each document focused on one job. Split and link when a document needs another job.

### Tutorial

Teach by having the reader build something. State what they will build. Give an early visible result, then make every step produce another observable result. Keep explanations short and link to deeper material.

### How-to guide

Help a competent reader reach a goal. Use direct commands. Skip background, teaching, and completeness for its own sake. Put optional paths after the common path.

### Reference

Record facts for lookup. Mirror the code or system it describes. Cover accepted values, defaults, limits, errors, and observable behavior. Generate reference data from code when possible.

### Explanation

Help the reader understand one bounded topic. Cover the reason, constraints, alternatives, and tradeoffs. Explain what the design does and why it won over the credible alternatives.

For code and architecture explanations, give the reader a working mental model instead of annotated source code:

1. State what the subsystem does and why it exists.
2. Define only the concepts needed to follow the flow.
3. Trace one concrete path from trigger to result, including data movement and decision points.
4. Name the files and symbols that own each decision.
5. End with non-obvious constraints, failure modes, and likely misconceptions.

Do not list every file, type, or function. Include only what the reader needs to answer the question or begin changing the subsystem.

## Write procedures

- Write steps as commands.
- Put warnings and conditions before the step they guard.
- Tell the reader what result to expect after important steps.
- Put the common path first and exceptions later.
- Do not narrate an operation in the passive voice.
- Do not mix a tutorial with a reference dump. Link to the reference instead.

## Write comments only for information code cannot express

Prefer code, types, tests, schemas, and lint rules over comments.

- Do not narrate the next line or restate a symbol's name.
- Delete comments that describe dead code, obvious control flow, or temporary implementation history.
- Keep comments that explain an external constraint, a non-obvious invariant, a deliberate tradeoff, or why the obvious implementation is wrong.
- Name the source of an external constraint. Link an issue, specification, protocol, or upstream bug when possible.
- Replace "do not remove" and similar warnings with an enforced type, test, runtime check, or lint rule when the repository can encode the constraint.
- Update or delete a comment in the same change that invalidates it.

## Keep technical claims honest

- Verify every symbol, path, option, count, and command against the current repository.
- Include the command that regenerates a generated count or tree.
- Do not claim runtime behavior from a successful build alone.
- Name uncertainty and missing evidence. Do not cover it with a hedge.
- Preserve established terminology unless it is wrong. Unnecessary renaming makes diffs harder to review.
- Point to evidence instead of narrating the whole investigation. Use a symbol, `file:line`, command, test result, trace, screenshot, issue, or specification.
- Separate observation from inference. Mark an inference when the evidence does not directly prove the claim.
- Report the exact check performed. Do not turn "the build passed" into "the feature works."
- Include failed or inconclusive checks when they change the reader's confidence or next action.

## Review

Before sending or committing prose, check it once:

1. Does the opening state what the reader needs to know or do?
2. Can any sentence lose words without losing meaning?
3. Does each instruction have one action and any condition in front?
4. Can any sentence be read two ways?
5. Does each concept keep one name?
6. Are the symbols, paths, commands, and claims verified?
7. Does the text sound like a person with evidence and a point of view?

If a rule makes the writing worse, rewrite the sentence another way. The rules serve the reader. A sentence that follows every rule and still sounds machine-written has failed.
