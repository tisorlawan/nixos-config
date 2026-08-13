# AWS ARN — learning state

Goal: working knowledge (read/write ARNs in daily AWS work). Background: new to AWS. Sessions: ~15 min.

## Concepts

| Concept | Status |
|---|---|
| What an ARN is: globally unique name; solves name collisions | learned |
| Six fields in fixed order: `arn:partition:service:region:account:resource` | learned |
| Global services leave fields empty (`s3:::`, `iam::`) — mechanism, not just "it's global" | **shaky** |
| Account field disambiguates same-named resources across accounts | **shaky** (took two tries) |
| Resource segment shapes: bare id (`reports`), `type/id` (`instance/i-0abc`), `type:name` (`function:foo`) | learned |
| Partitions: `aws`, `aws-cn`, `aws-us-gov` | learned |
| `*` wildcard in policies; bucket ARN ≠ object ARNs (`ListBucket` vs `GetObject`) | learned |
| `?` wildcard (single char) | mentioned only, untested |

## Re-test at start of next session

1. Why does `arn:aws:s3:::logs` contain three consecutive colons? (Answer must mention the mechanism: six fixed slots, empty region field.)
2. Bucket `logs` exists in account 111 and 222 — which ARN field differs, and why must it be inside the ARN?
3. What does `?` match, and how does it differ from `*`?

## Not yet covered

- Policy variables (`${aws:username}`)
- Trust policies and cross-account resource references
- Per-service quirks beyond S3/IAM/EC2/Lambda/DynamoDB

## Session log

- 2026-08-21 — session 1: chunks 1–3 taught, explain-back passed. Corrections mid-session: empty-field mechanism, account-as-disambiguator → both on re-test list.
