# Review Posting Templates

Use these templates when posting review results via `gh pr review`.

## LGTM — Approve

When all merge readiness criteria are met:

```bash
gh pr review <PR_NUMBER> --approve --body "$(cat <<'EOF'
## ✅ LGTM

**Summary**: [One sentence describing what this PR does]

**Assessment**: The implementation correctly addresses the PR's goal.

**Files reviewed**: [e.g., "3 source files, 2 test files, lock files updated"]

[Optional: Highlights or minor suggestions that don't block merge]

---
*Reviewed by Claude*
EOF
)"
```

## Changes Requested — Block Merge

When Critical or High severity issues are found:

```bash
gh pr review <PR_NUMBER> --request-changes --body "$(cat <<'EOF'
## ⚠️ Changes Requested

**Summary**: [One sentence describing what this PR does]

**Assessment**: [Why this is not ready to merge]

### Issues Found
[List of Critical/High severity issues with file:line references]

### 🤖 AI Fix Prompt
<details>
<summary>Copy this prompt to your AI agent to fix all issues at once</summary>

\`\`\`\`
Fix the following issues in this repository:

In `@path/to/file.ts`:
- Line N: [Describe what is wrong and exactly how to fix it, referencing
specific symbols, functions, or variables so the agent can locate the code.
Include enough context for the agent to make the change without ambiguity.]

In `@path/to/another-file.ts`:
- Around line N-M: [Describe the problem and the concrete fix, specifying
which function/class/variable to modify and what the expected behavior
should be after the fix.]
\`\`\`\`

</details>

---
*Reviewed by Claude*
EOF
)"
```

## Minor Suggestions — Comment + Approve

When only Medium/Low severity suggestions exist:

```bash
gh pr review <PR_NUMBER> --comment --body "$(cat <<'EOF'
## 💬 Review Complete

**Summary**: [One sentence describing what this PR does]

**Assessment**: The implementation is acceptable with minor suggestions.

### Suggestions (non-blocking)
[List of Medium/Low severity suggestions]

### 🤖 AI Fix Prompt
<details>
<summary>Copy this prompt to your AI agent to apply suggestions</summary>

\`\`\`\`
Apply the following suggestions in this repository:

In `@path/to/file.ts`:
- Around line N-M: [Describe the suggestion and how to apply it, referencing
specific symbols so the agent can locate and modify the code unambiguously.]
\`\`\`\`

</details>

---
*Reviewed by Claude*
EOF
)"
```

Then approve:

```bash
gh pr review <PR_NUMBER> --approve --body "✅ LGTM - Minor suggestions provided above but not blocking."
```

## Large PR Skip Notice

When diff exceeds 5000 lines:

```bash
gh pr comment <PR_NUMBER> --body "$(cat <<'EOF'
## ⏭️ Auto Review Skipped

This PR has **[LINE_COUNT] lines** of changes, exceeding the auto review limit (5000 lines).

**Options:**
- Split the PR into smaller units
- Add the \`skip-claude-review\` label and request a manual review

---
*Automated message*
EOF
)"
```

## Review Failure Notice

When the review process encounters an error:

```bash
gh pr comment <PR_NUMBER> --body "$(cat <<'EOF'
## ⚠️ Automated Review Failed

The Claude PR review encountered an error and could not complete.

**Possible reasons:**
- API timeout or rate limiting
- Large diff size exceeding processing limits
- Network connectivity issues

Please request a manual review or retry the workflow.

---
*Automated message*
EOF
)"
```

## Severity Definitions

| Severity | Description | Action |
|----------|-------------|--------|
| **Critical** | Security vulnerability, data loss risk, crash | Request changes |
| **High** | Logic error, regression, breaking change | Request changes |
| **Medium** | Missing edge case, suboptimal approach | Comment (non-blocking) |
| **Low** | Style suggestion, minor improvement | Comment (non-blocking) |
