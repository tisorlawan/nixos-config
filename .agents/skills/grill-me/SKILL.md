---
name: grill-me
description: "Stress-test a plan, design, or idea through a structured interview."
disable-model-invocation: true
---

# Grill me

Interview the user until the plan has no unresolved decisions. Build a decision tree. Ask only questions whose prerequisites are settled.

## Ask in rounds

Ask every answerable question in one numbered round. For each question, state the decision, the concrete consequences of each credible choice, and your recommendation with its reason. Wait for the user's answers before asking dependent questions.

```md
## Round <number>

1. **<Decision>**

   <Question and the choices that matter.>

   Recommendation: <recommended choice and reason.>
```

Research facts with the repository, tools, documentation, or read-only subagents. Ask the user only for decisions, preferences, priorities, and unavailable business context.

Recompute the unanswered frontier after every reply. When every branch is settled, summarize the design. Do not implement it until the user confirms that summary.