# Subagent model routing

Use models by role. Cheap retrieval belongs on Luna. Decisions that shape the
answer or the code belong on Sol.

| Role | Model | Reasoning effort |
| --- | --- | --- |
| Repository exploration, evidence collection, and narrow call tracing | `gpt-5.6-luna` | `medium` |
| Explanation, synthesis, conflict resolution, critique, and design | `gpt-5.6-sol` | `high` |

The root agent should run on `gpt-5.6-sol`. A skill cannot select the root
agent's model, so the caller or Codex session configuration owns that choice.

## Spawn contract

For every routed subagent:

1. Set `model` and `reasoning_effort` explicitly from the table above.
2. Set `fork_turns` to `"none"`. A full-history fork inherits the parent's
   model and cannot apply a model override.
3. Put all required context in the task prompt. Include the original question,
   the exact exploration angle or judgment task, repository paths, applicable
   constraints, and any artifacts the agent must consume.
4. Keep Luna tasks bounded and non-mutating. Use read-only execution when the
   required tools support it. If an MCP requires agent mode, prohibit writes in
   the task prompt. Ask for evidence and structured findings, not conclusions
   that require architectural or product judgment.
5. Escalate a Luna slice to Sol when the evidence conflicts, the trace is
   incomplete, or resolving the result requires judgment. Do not guess across
   a gap.

This file is authoritative. Orchestrating skills must reference it instead of
declaring their own default models.
