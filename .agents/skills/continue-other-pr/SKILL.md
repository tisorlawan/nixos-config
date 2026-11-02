---
name: continue-other-pr
description: Continue someone else's PR on its existing branch so they stay the author. Use when the user asks to take over, continue, or finish another person's PR.
---

# Continue Other PR

Take responsibility for finishing the original goal while preserving the
original contributors' credit. Do not defend an implementation just because
another agent already built it.

Read the PR, including review findings and the user's later corrections.
Resolve it to the actual code and current head, and account for uncommitted
work. Treat the PR description and prior discussion as context, not proof.

Continue the existing PR: commit to its head branch and push there, so the
original author stays the PR author. Never open a new or replacement PR. Do not
overwrite unrelated work. If you cannot push to the head branch, stop and
report the access blocker.

Preserve Git authorship and existing co-author trailers. If the work will be
squashed, preserve human author/co-author credit in the merge commit too, using
verified identities rather than guessed emails. Model attribution is not a
substitute for contributor credit.

Use `modernize` to update the continuation against its intended base and
current architecture. Rework what is necessary to finish the same goal, not
unrelated features. Simplify the implementation without dropping intended
behavior or surfaces. Recheck the PR head too: it may have changed while
you were working.

Independently verify the original failure and realistic workflows, following
repository guidance and permissions. Green mocked tests do not prove the user
experience works. State what remains unverified.

After pushing, use `babysit-pr` on the same PR. Use `leaving-pr-comments` for
replies. Merge or close the PR only when authorized.

Report what you inherited, what you changed, how you verified it, how credit
was preserved, and any remaining decision.
