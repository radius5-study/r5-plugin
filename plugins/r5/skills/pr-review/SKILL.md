---
name: pr-review
description: This skill should be used when the user asks to "review a PR", "review pull request", "check this PR", "look at this PR", "is this PR ready to merge", "PRレビューして", "PRをレビュー", "PR見て", "コードレビュー", or when performing automated or manual code reviews on GitHub pull requests. Provides a structured, incremental review workflow with security checks, file prioritization, and merge readiness assessment.
disable-model-invocation: true
---

# PR Review Workflow

## Hard Rules (MUST follow)

1. **No Low severity reports.** Do NOT report style nits, type annotation improvements, debug statements, import order, documentation suggestions, or any Low severity finding. This applies to your own findings AND all agent outputs. If unsure, don't report it.
2. **Always include AI Fix Prompt.** Every review with issues MUST end with a `### 🤖 AI Fix Prompt` section per **`references/review-templates.md`**.
3. **Always post via `gh pr review`.** Never just output text. Always run the `gh pr review` command.
4. **Never fetch full diff if >300 lines.** Review file by file with `gh pr diff <PR_NUMBER> -- path/to/file`.
5. **Never review lock files line-by-line.** Acknowledge their presence briefly.

## Review Steps

### 1. Gather Context

Read the repository's `CLAUDE.md`, then collect PR metadata:

```bash
gh pr view <PR_NUMBER> --json title,body,baseRefName,headRefName,files,commits
gh pr diff <PR_NUMBER> --name-only
gh pr diff <PR_NUMBER> | wc -l
```

**Diff size tiers:**
- **>5,000 lines** → Skip review, post skip notice from **`references/review-templates.md`**
- **>300 lines or >10 files** → Review file by file (see Hard Rule 4)
- **≤300 lines and ≤10 files** → Review full diff at once

**Check for previous review:** Try to load the review cache artifact, then check for previous review content on GitHub:

```bash
# Download previous review metadata (from CI artifacts)
gh run download --name claude-review-pr-<PR_NUMBER> --dir .claude-reviews/ 2>/dev/null

# Read cache if available — contains head_sha, reviewed_at, review_outcome
cat .claude-reviews/pr-<PR_NUMBER>.json 2>/dev/null

# Get previous review content from GitHub
gh pr view <PR_NUMBER> --json comments,reviews --jq '
  [(.comments[]? | select(.body | contains("Reviewed by Claude")) | {body: .body, at: .createdAt}),
   (.reviews[]? | select(.body | contains("Reviewed by Claude")) | {body: .body, at: .createdAt})]
  | sort_by(.at) | last | .body'
```

If a previous review exists: avoid repeating the same feedback, focus only on new changes since the last review.

### 2. Review Code

Classify files by priority per **`references/file-categories.md`** and review in order: source → tests → config → lock files (acknowledge only).

**Focus on:**
- Bugs, logic errors, regressions in NEW/MODIFIED code
- Missing edge cases relevant to the PR's goal
- Breaking changes
- Security vulnerabilities (see **`references/security-patterns.md`**)

**Severity threshold:**
- 🔴 **Critical/High** → Always report. Block merge.
- 🟡 **Medium** → Only if directly relevant to PR's goal. Max 2-3 items.
- 🔵 **Low** → Never report. (Hard Rule 1)

### 3. Run Review Agents

Use pr-review-toolkit agents selectively — only invoke what's relevant to the changes:

- **code-reviewer** → All source code changes
- **pr-test-analyzer** → Only if tests were added/modified
- **silent-failure-hunter** → Only if error handling was changed
- **type-design-analyzer** → Only if types/interfaces were modified
- **comment-analyzer** → Only if significant docstrings were added

**Filter agent outputs by the same severity threshold.** Discard all Low findings from agents.

### 4. Post Review

Determine merge readiness and post via `gh pr review` using templates from **`references/review-templates.md`**:

- **No Critical/High issues** → `gh pr review --approve` (LGTM)
- **Critical/High issues found** → `gh pr review --request-changes`
- **Only Medium suggestions** → `gh pr review --comment` then `--approve`

Populate the `### 🤖 AI Fix Prompt` section with self-contained fix instructions (exact file paths, line numbers, what to change and why). (Hard Rule 2)
