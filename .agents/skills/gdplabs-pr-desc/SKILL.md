---
name: gdplabs-pr-desc
description: "Write a GDP Labs PR title and description to PR.md. Use when asked to prepare, draft, or update a pull request description for the current branch."
disable-model-invocation: true
---

# GDP Labs PR description

Create or replace `PR.md` for the current branch. Infer the base branch from Git evidence. The user does not need to provide a base commit or branch.

Do not create or update a pull request with `gh`. Do not stage or commit `PR.md`.

## Find the base

Do not assume `main`, `master`, or `develop`.

Use the first source that gives a clear answer:

1. If a pull request already exists for the current branch, read its base with `gh pr view --json baseRefName`. Use the matching local or remote-tracking branch.
2. Inspect branch configuration, remote HEAD, reflogs, and local remote-tracking branches. Include common integration and release branches such as `develop`, `main`, `master`, and `release/*` only when they exist.
3. For each credible candidate, calculate `git merge-base --fork-point <candidate> HEAD`. If that fails, calculate `git merge-base <candidate> HEAD`.
4. Compare the candidates in the commit graph. Prefer the candidate whose fork point best explains the branch history: the most recent fork point that is an ancestor of `HEAD`, with the branch commits forming one coherent change. Use repository conventions and recent merged pull requests to break a tie.

Record the selected branch and fork-point commit for your own diff commands. Do not ask the user for a base. If Git history is ambiguous, choose the best-supported candidate and state the assumption in `Additional Notes`.

Read the complete change with:

```text
git diff --stat <fork-point> HEAD
git diff <fork-point> HEAD
git log --oneline <fork-point>..HEAD
```

Read changed files when the diff alone does not explain the behavior. Inspect the original user request or linked issue when available. Never infer the problem from filenames alone.

## Write the title

PR titles usually become commit messages. Inspect recently merged pull requests and recent Git history before writing the title. Follow the repository's actual convention. Use Conventional Commits when that is the established form:

```text
<type>(<scope>): <description>
```

Common types include `feat`, `fix`, `docs`, `style`, `refactor`, `test`, and `chore`.

Keep the title concise and readable. Explain the outcome or why the change matters, not an internal mechanism. Start the description with a verb when that reads naturally.

Bad:

```text
perf(server): negotiate permessage-deflate on the websocket
```

Good:

```text
perf(server): cut websocket frame size by 70% with gzip
```

Do not invent measurements. Use a number only when the diff, tests, benchmark output, issue, or user request proves it.

## Write the description

Open `Summary` with the problem in plain language. Base it on the user's request, issue, observed failure, or other repository evidence. Then explain the solution briefly.

Do not open with a list of files, symbols, deleted helpers, or implementation steps.

Bad:

```text
Removed implicit workspace carry-over from every new-thread entry point. Deleted the contextual option builders and seed-context machinery.
```

Good:

```text
New threads on existing worktrees ignored the user's "new worktree" defaults. This change makes those preferences apply consistently.
```

The good version names the user-visible problem first. The rest of the summary can explain the design and any important tradeoff.

Write for a reviewer:

- Explain what was wrong and why the change matters.
- Explain the chosen solution, not every edit.
- Mention a design constraint or migration only when it helps review.
- Use repository terms and real symbol names.
- Do not claim tests, measurements, compatibility, or issue links without evidence.
- Keep sections concise. Remove placeholder comments from the final file.

## Write `PR.md`

Use this exact section order:

```markdown
# <pull request title>

## Summary

<problem first, then the solution>

## How to Test

1. <specific command or reviewer action>
2. <specific expected result>

## Related Issues

<Closes #123, Fixes #456, Related to #789, or "None">

## Author Checklist

- [ ] Code follows team coding standards and style guide
- [ ] Self-reviewed the code changes
- [ ] Added or updated tests for new functionality
- [ ] All tests pass locally
- [ ] Code is documented where needed
- [ ] Synced with the selected base branch
- [ ] PR title follows the repository convention
- [ ] Commits are meaningful and scoped

## Additional Notes

1. [GDP Labs Coding and Code Review Best Practices](https://docs.google.com/document/d/1QCzqnxXPEN_fatbTaSt-LVL9vFKoEBrQ6zTCt3tbCWU/edit)
```

Mark a checklist item only when repository evidence proves it. Leave unverified items unchecked. Strike through an item only when it does not apply:

```markdown
- [ ] ~Added or updated tests for new functionality~
```

Add testing caveats, rollout details, screenshots, the inferred-base assumption, or reviewer context under `Additional Notes` only when needed. Keep the GDP Labs practices link.

## Check the result

Before finishing:

1. Re-read `PR.md` against the diff and commit range.
2. Confirm the title matches recent repository conventions.
3. Confirm the summary starts with the problem rather than an implementation inventory.
4. Confirm every test step is runnable and has an observable expected result.
5. Confirm every checked box and factual claim has evidence.
6. Confirm `PR.md` contains no template comments or invented issue references.
