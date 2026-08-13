---
name: domain-modeling
description: "Maintain a project's canonical terminology and record consequential architecture decisions."
disable-model-invocation: true
---

# Domain modeling

Use this skill when the user explicitly wants to define or revise domain language, `CONTEXT.md`, or architecture decision records. Keep terminology and decisions separate from implementation details.

## Choose the context

Use the root `CONTEXT.md` unless `CONTEXT-MAP.md` identifies a narrower context. Create a context file only when a term has been settled. Create `docs/adr/` only when a decision needs a record.

## Sharpen the model

- Compare new terms with the existing glossary. Surface conflicts immediately.
- Replace vague or overloaded terms with one canonical name.
- Test relationships with concrete edge cases.
- Check statements about current behavior against the code. Surface contradictions instead of choosing a version silently.
- Update the glossary when a term is settled. Do not collect unresolved wording in it.

Use `CONTEXT-FORMAT.md` for the glossary. `CONTEXT.md` defines terms. It does not contain implementation notes or a product specification.

## Record decisions sparingly

Create an ADR only when the decision is costly to reverse, surprising without context, and chosen from real alternatives. Use `ADR-FORMAT.md`. Keep the record short and name the decision, context, and reason.

Do not create or edit context files or ADRs until the relevant term or decision is settled.