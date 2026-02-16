---
name: pr-review
description: This skill should be used when the user asks to "review a PR", "review pull request", "check this PR", "look at this PR", "is this PR ready to merge", "PRレビューして", "PRをレビュー", "PR見て", "コードレビュー", or when performing automated or manual code reviews on GitHub pull requests. Provides a structured, incremental review workflow with security checks, file prioritization, and merge readiness assessment.
disable-model-invocation: true
---

# PR Review Workflow

Structured code review process for Copainter pull requests. Prioritize correctness, security, and actionable feedback. Do NOT report style nits or minor improvements.

## Review Process Overview

### Step 0: Read Project Guidelines

First, read the repository's `CLAUDE.md` using the Read tool to understand project conventions and guidelines. Apply these conventions throughout the review.

### Step 1: Gather PR Context

Collect PR metadata before reviewing code:

```bash
# Get PR details
gh pr view <PR_NUMBER> --json title,body,baseRefName,headRefName,files,commits

# Get changed file list
gh pr diff <PR_NUMBER> --name-only

# Calculate diff size
gh pr diff <PR_NUMBER> | wc -l
```

**Diff size tiers** (calculated from `wc -l` above):

| Total lines | Action |
|---|---|
| >5,000 | Skip review entirely — post skip notice from **`references/review-templates.md`** |
| >300 or >10 files | Review incrementally, file by file (Step 4) |
| ≤300 and ≤10 files | Review full diff at once |

### Step 2: Check for Previous Reviews

When updating a review on a previously-reviewed PR:

```bash
# Find previous Claude review
gh pr view <PR_NUMBER> --json comments,reviews --jq '
  [
    (.comments[]? | select(.body | contains("Reviewed by Claude")) | {body: .body, at: .createdAt}),
    (.reviews[]? | select(.body | contains("Reviewed by Claude")) | {body: .body, at: .createdAt})
  ] | sort_by(.at) | last | .body
'

# Check recent commits since last review
gh pr view <PR_NUMBER> --json commits --jq '.commits[-10:][] | .oid[:7] + " " + .messageHeadline'
```

When previous review exists:
- Check if previously raised issues have been addressed
- Avoid repeating the same feedback
- Focus ONLY on new changes since the last review

### Step 3: Categorize and Prioritize Files

Classify changed files by review priority. See **`references/file-categories.md`** for the full classification rules.

**Key rule:** Never review lock file contents line-by-line. Acknowledge their presence briefly.

### Step 4: Incremental Review Strategy

**For large diffs (>300 lines or >10 files):** Review files one at a time using the Read tool, in priority order:
1. Source code files first
2. Test files second
3. Config files third
4. Lock files last (acknowledge only)

```bash
# Review individual file diff
gh pr diff <PR_NUMBER> -- path/to/file
```

**For small diffs (<300 lines):** Review the full diff at once:
```bash
gh pr diff <PR_NUMBER>
```

### Step 5: Review Focus Areas

Based on the PR's stated purpose, review ONLY:
- Whether changes correctly implement the stated goal
- Bugs or logic errors in NEW/MODIFIED code
- Missing edge cases relevant to the change
- Breaking changes or regressions
- Security vulnerabilities

**Severity threshold — what to report:**
- 🔴 **Critical/High**: ALWAYS report. These block merge.
- 🟡 **Medium**: Report only if directly relevant to the PR's goal. Keep to 2-3 items max.
- 🔵 **Low**: Do NOT report. No style nits, no minor improvements, no `console.log` mentions.

**DO NOT comment on:**
- Code style preferences (naming, formatting, import order)
- Type annotation improvements (`: any`, missing generics, etc.)
- Debug statements (`console.log`, `print`) unless in production-critical paths
- Unrelated improvements or refactoring suggestions
- General best practices not directly relevant to this PR
- Pre-existing issues in untouched code
- Documentation or comment suggestions

### Step 6: Security Scan

Run security checks on changed source files. See **`references/security-patterns.md`** for grep patterns and detection rules.

Flag only Critical/High security issues. Ignore Low severity patterns (e.g., `console.log`, `print`).

### Step 7: Run Specialized Review Agents

Use pr-review-toolkit agents selectively based on the actual changes. Only invoke agents relevant to what was modified:

- **code-reviewer** — Check code quality against project guidelines. Use on all source code changes.
- **pr-test-analyzer** — Analyze test coverage. Use only if tests were added or modified.
- **silent-failure-hunter** — Check error handling. Use only if error handling code was changed.
- **type-design-analyzer** — Analyze type design. Use only if types or interfaces were modified.
- **comment-analyzer** — Verify comment accuracy. Use only if significant comments or docstrings were added.

Do NOT run all agents on every PR. Match agents to the changes.

**Important:** Each agent may produce its own findings. Apply the same severity threshold from Step 5 to agent outputs — discard any Low severity findings and limit Medium to 2-3 items max. Only include Critical/High findings in the final review.

### Step 8: Determine Merge Readiness

**MERGE READY (LGTM)** — all true:
- No Critical or High severity bugs
- Implementation correctly addresses stated goal
- No undocumented breaking changes
- No security vulnerabilities introduced
- No obvious logic errors

**NOT MERGE READY** — any true:
- Critical or High severity bugs found
- Implementation does not match stated goal
- Undocumented breaking changes
- Security vulnerabilities introduced
- Obvious logic errors causing runtime failures

See **`references/review-templates.md`** for severity level definitions.

### Step 9: Post Review

Post the review to GitHub using `gh pr review` with the matching template from **`references/review-templates.md`**:
- `gh pr review --approve` for LGTM
- `gh pr review --request-changes` for blocking issues
- `gh pr review --comment` then `--approve` for minor suggestions only

The templates in **`references/review-templates.md`** include the `### 🤖 AI Fix Prompt` section. When filling in the template, you MUST populate this section with concrete, actionable fix instructions for every issue mentioned in the review. Do NOT skip it or leave it as placeholder text.

**AI Fix Prompt rules:**
- Each instruction must be self-contained — the AI agent has no context from the review
- Reference exact file paths, line numbers, function/variable names
- Describe both "what is wrong" and "how to fix it" concretely
- Group instructions by file path

## Anti-Hallucination Rules

- NEVER fetch entire PR diff if >300 lines — use incremental file-by-file review
- NEVER review lock files line-by-line
- NEVER make assumptions about code not yet read
- NEVER post a review without running `gh pr review` — always post to GitHub, never just output text
- NEVER post a review that has issues without a populated `### 🤖 AI Fix Prompt` section
- NEVER report Low severity issues (style, minor improvements, debug statements)
- ALWAYS understand each file before moving to the next
- If unsure about something, re-read the specific file

## Additional Resources

### Reference Files

- **`references/file-categories.md`** — File priority classification rules
- **`references/security-patterns.md`** — Security grep patterns and detection rules
- **`references/review-templates.md`** — Review posting templates (LGTM, changes requested, minor suggestions)
