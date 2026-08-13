---
name: grill-with-docs
description: "Stress-test an engineering design through a structured interview, then record settled terminology and consequential decisions."
disable-model-invocation: true
---

# Grill with docs

Interview the user until the engineering design has no unresolved decisions. Build a decision tree. Ask every question whose prerequisites are settled in one numbered round. For each question, state the decision, the concrete consequences of each credible choice, and your recommendation with its reason. Wait for the user's answers before asking dependent questions.

Research facts with the repository, tools, documentation, or read-only subagents. Ask the user only for decisions, preferences, priorities, and unavailable business context.

When a term or decision is settled:

- Compare the term with existing `CONTEXT.md` language. Surface conflicts and choose one canonical name.
- Create or update `CONTEXT.md` only for settled domain terms. Keep implementation details and unresolved questions out of it.
- Create an ADR only when the decision is costly to reverse, surprising without context, and chosen from real alternatives.
- Store ADRs in `docs/adr/` with the next sequential filename. Keep the record short: context, decision, and reason.

Do not create a glossary entry or ADR before the user settles the relevant term or decision. When every branch is settled, summarize the design. Do not implement it until the user confirms that summary.