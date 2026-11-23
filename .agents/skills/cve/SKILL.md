---
name: cve
description: Fix dependency vulnerabilities using user-provided Trivy scan results. Use when the user asks to remediate CVEs from a Trivy scan.
---

1. **Trust the provided scan.** Use the user-provided Trivy scan results as-is. Do not re-run Trivy or attempt to reproduce the vulnerabilities locally.
2. **Skip local testing.** Do not run local builds or tests to verify the fixes.
3. **Handle upgrade conflicts.** If a dependency cannot be upgraded due to version conflicts or compatibility issues with other dependencies, ask the user for confirmation before adding the CVE to `.trivyignore`.
4. **Commit each change separately** without any attribution or co-author trailers:
   - **Dependency upgrade** (subject line only, no body):
     ```text
     fix(deps): upgrade <package> from <old_version> to <new_version> for <CVE_ID>
     ```
   - **Added to `.trivyignore`** (include a commit body explaining why it is being ignored for now):
     ```text
     fix(deps): add <CVE_ID> to .trivyignore
     ```
5. **Push changes.** Push the commits to the remote Git repository once all fixes are committed.
