---
name: review-loop
description: Use when the user says "review loop" or "<model> loop" (for example "sol loop" or "opus loop"). The user must name the reviewer model.
---

# Review loop

Use a reviewer model named by the user to review your code changes in a loop, either before or after opening a pull request.

Make the smallest changes needed to fix real issues. Watch for scope creep, and push back when a suggestion goes beyond the goal.

## Rules and budget

- **Default limit.** Run at most 3 rounds. Round 1 is a full review. Later rounds check only open findings and code changed since the previous round.
- **Extended limit.** Extend to 5 rounds only when the user asks, or when a `blocker` or `should` finding stays open with evidence in security, permissions, auth, data loss, or state and concurrency.
- **Early stop.** Stop if a round returns only `nit` findings. Declined nits and comment, doc, or format-only edits do not need another round.
- **Single reviewer.** Run one reviewer at a time. The reviewer must not start subagents or other reviewers.
- **Ledger.** Track every finding across rounds with its ID, severity, and outcome (`fixed`, `disagree`, or `declined`, with evidence). Record usage stats only if the runtime returns them, and never guess usage.

## 1. Confirm the reviewer model

The user must name the reviewer model, such as `sol`, `opus`, or an exact model ID. Any model is allowed. A phrase like `<model> loop` names the model.

If the user did not name a model, ask which model to use before starting. Do not pick a default, and never substitute a different model.

## 2. Define scope and base

1. Run `git status --short`. Do not stash, discard, or include unrelated changes. If unrelated edits exist, limit the review to the paths for this change only if they separate cleanly. Otherwise stop and ask the user.
2. Run `git fetch origin`, then determine the base commit:
   - **Pull request.** Run `gh pr view <n> --json baseRefName,headRefOid`. Check out the PR branch only if the working tree is clean. Confirm `HEAD` is the PR head, or ahead of it only by this change. Set the base to `git merge-base HEAD origin/<baseRefName>`.
   - **Local branch.** Set the base to `git merge-base HEAD origin/<default-branch>`.
   - **No remote.** Use a base the user names, or `HEAD` for uncommitted changes only.
3. Define the reviewed change as the diff from `<base>` to the working tree in the scoped paths, plus any untracked files in those paths. Keep the same base and diff command across all rounds.
4. Record the starting diff size with `git diff --shortstat <base>` so you can compare before and after in the final report.
5. Write 1 to 2 sentences describing the intent and what is out of scope.
6. Run the checks that cover this change. Do not send code that this change breaks. Note any missing or pre-failing checks in the reviewer brief.

## 3. Start the reviewer

### In T3 Code

- Call `orchestrator_capabilities` to resolve the model. If T3 tools are not listed, try one direct `orchestrator_capabilities` call first.
- If the user gave an exact model ID, use it. If the user gave a family name, pick the latest model in that family. If the name matches several families or none, ask the user. Never hardcode a model ID.
- Record provider, model, and effort only if the tool exposes them.
- Start every round with `delegate_task` using `role: "review"` and `mode: "async"`.
- Save `taskId`, and generate a new `clientRequestId` for each round.
- Treat `childThreadId` as storage only, not as the target for the next round.
- Do not use `t3_thread_send`, `create_threads`, or `t3_thread_launch` for review.

### Outside T3 Code

- Use a native subagent running the named model, and save its ID for follow-up rounds.
- In Claude Code, use a custom subagent only if it is configured to run the named model.
- If no available route runs the named model, report the blocker and stop. Do not substitute another model.

### While the review runs

- Do not edit files in scope while the reviewer is running.
- Wait for the completion notice. Do not poll or start a second reviewer.
- A timeout, error, or empty reply is not approval. If a run fails, cancel it, verify it stopped, and restart it with the current ledger.

### Round 1 brief

T3 child tasks receive no conversation history, so make the brief self-contained:

```text
Review only. Do not edit files, commit, push, comment on PRs, or start subagents.

Repo: <abs path>
Base: <sha>
Intent: <1-2 sentences>
Out of scope: <1-2 sentences>
Checks: <commands and results, including missing or pre-failing checks>

Inspect the change with `git diff <base> [-- <paths>]` and `git status --short` (read any untracked files in scope). Read the surrounding code.

Focus on bugs, broken callers, and mismatches with the intent. Skip style issues unless they hide a bug. Hold the change to the smallest diff needed, and flag any code, tests, or guards that the intent does not need.

Severity levels:
- blocker: the intended behavior is wrong.
- should: a real bug callers will hit within the stated intent.
- nit: everything else, including other paths, rare cases, minor performance costs, and extra compatibility.

Reply in this format, keeping finding IDs stable across rounds:
VERDICT: APPROVE | CHANGES
S1 [blocker|should|nit] <file>:<line> <claim>. Fix: <suggestion>
```

## 4. Triage findings and apply fixes

Verify every finding and its severity yourself. Reclassify issues about other paths, rare cases, or small performance costs as `nit`, regardless of the label the reviewer gave them.

Handle each finding in one of three ways:

- **Agree.** Make the smallest fix for the specific case that happened. Prefer deleting or narrowing code over adding a lock, cache, helper, or option. Add one focused test that fails without the fix if the intent needs it.
- **Disagree.** Explain why with concrete evidence, such as a `file:line` reference, test, or command output. Do not agree just to end the loop.
- **Out of scope or nit.** Decline it in one line and record it as a follow-up.

After handling all findings, update the ledger, re-run covering checks, and run `git diff --shortstat <base>`. If review fixes grew the diff unnecessarily, trim the diff before starting another round.

## 5. Run the next round

Start another round only if budget remains and at least one of these holds:

- A `blocker` or `should` finding is still open.
- Behavior code changed.
- The reviewer's approval does not cover the current behavior diff.

Skip a new round if you only declined nits or made comment, doc, or format-only edits.

In T3 Code, start a fresh `delegate_task` with a new `clientRequestId`. Outside T3 Code, follow up on the saved native subagent ID.

Include all of the following in the follow-up message:

- The Round 1 brief context.
- The updated ledger, marking each finding as `fixed:`, `disagree:`, or `declined:` with evidence.
- The same base diff command, plus the changes made since the last round.
- Instructions to check only open finding IDs and changed code, and to mark each previous ID as `resolved` or `still open: <reason>`.

## 6. Stop, push, and report

### Stop conditions

- **Agreed.** Stop when the reviewer returns `APPROVE` on the current behavior diff, no `blocker` or `should` finding stays open, and you have no remaining concern of your own.
- **Stuck.** Stop if a finding stays disputed after two replies, or if the round budget runs out. Reaching the budget limit is not approval. Summarize both sides in 2 to 3 lines each and let the user decide.

### Pushing and PR description

Do not push during the loop. Push after agreement only if the user asked to push, ship, or update the PR.

If you push to a PR, add this line to the PR description above the model blurb:

`Reviewed with review-loop: <N> rounds with <model>. Verdict: approved`

Add `on <effort>` after `<model>` only if the runtime reported the effort level.

### Final report

Report the following to the user:

- Number of rounds and the reviewer model.
- What changed because of the review.
- Diff size before and after (`git diff --shortstat <base>`).
- Fixed and declined findings, with reasons.
- Usage stats if the runtime exposed them, or state that usage was not exposed.
- Whether you pushed the changes.
