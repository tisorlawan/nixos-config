---
name: grilling
description: "Interview the user to expose and settle unresolved decisions in a plan, design, or idea."
disable-model-invocation: true
---

# Grilling

Interview the user until the plan has no unresolved decisions. Build a decision tree. Each decision unlocks the decisions that depend on it.

## Ask in rounds

The frontier contains decisions whose prerequisites are already settled. Ask every frontier question in one round. Do not ask a question whose answer depends on another open question.

For each question:

1. State the decision and the concrete consequence of each credible choice.
2. Give a recommendation and explain why.
3. Wait for the user's answer before asking dependent questions.

Use this format:

```md
## Round <number>

1. **<Decision>**

   <Question and the choices that matter.>

   Recommendation: <recommended choice and reason.>
```

Recompute the frontier after every answer. The interview ends when every branch is settled.

## Research facts, ask for decisions

Find facts from the repository, tools, documentation, or read-only subagents. Do not ask the user for information you can discover. Ask the user only for decisions, preferences, priorities, and unavailable business context.

Do not implement, edit files, or commit changes while grilling. First summarize the settled design. Continue only after the user confirms that summary.