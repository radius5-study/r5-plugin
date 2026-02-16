---
name: pr-review
description: This skill should be used when the user asks to "review a PR", "review pull request", "check this PR", "look at this PR", "is this PR ready to merge", "PRレビューして", "PRをレビュー", "PR見て", "コードレビュー", or when performing automated or manual code reviews on GitHub pull requests. Provides a structured, incremental review workflow with security checks, file prioritization, and merge readiness assessment.
disable-model-invocation: true
---

# PR Review Workflow

Structured code review process for Copainter pull requests. Prioritize correctness, security, and actionable feedback over style nits.

## Review Process Overview

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

DO NOT comment on:
- Code style in unchanged lines
- Unrelated improvements or refactoring suggestions
- General best practices not directly relevant to this PR
- Pre-existing issues in untouched code

### Step 6: Security Scan

Run security checks on changed source files. See **`references/security-patterns.md`** for grep patterns and detection rules.

Flag security issues as **Critical** and require changes.

### Step 7: Determine Merge Readiness

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

### Step 8: Compose AI Fix Prompt

**MANDATORY** — Do this BEFORE posting the review. Whenever any issues or suggestions are found (any severity), you MUST compose a `### 🤖 AI Fix Prompt` section to include in the review body.

This section aggregates all issues into a single, copy-pasteable prompt for AI-assisted bulk fixes. It MUST be included in the review body that gets posted in Step 9.

Format:

```
### 🤖 AI Fix Prompt
<details>
<summary>Copy this prompt to your AI agent to fix all issues at once</summary>

\`\`\`
Fix the following issues in this repository:

In `@path/to/file.ts`:
- Line 42: [Describe the problem and the exact fix, referencing specific
symbols, functions, or variables so the agent can locate and modify
the code without ambiguity.]

In `@path/to/another-file.ts`:
- Around line N-M: [Describe the problem and the concrete fix, specifying
which function/class/variable to modify and what the expected behavior
should be after the fix.]
\`\`\`

</details>
```

**Rules for AI Fix Prompt:**
- Include ALL issues from the review (Critical, High, Medium, Low)
- Each instruction must be self-contained — the AI agent has no context from the review above
- Reference exact file paths, line numbers, function/variable names
- Describe both "what is wrong" and "how to fix it" concretely
- Group instructions by file path

### Step 9: Post Review

Compose the COMPLETE review body first (issues + AI Fix Prompt from Step 8), then post using the appropriate template from **`references/review-templates.md`**:
- `gh pr review --approve` for LGTM
- `gh pr review --request-changes` for blocking issues
- `gh pr review --comment` + `--approve` for minor suggestions only

**IMPORTANT:** The review body MUST already contain the `### 🤖 AI Fix Prompt` section from Step 8 before posting. Do NOT post the review without it.

## Anti-Hallucination Rules

- NEVER fetch entire PR diff if >300 lines — use incremental file-by-file review
- NEVER review lock files line-by-line
- NEVER make assumptions about code not yet read
- NEVER post a review containing issues without the `### 🤖 AI Fix Prompt` section — compose it in Step 8 BEFORE posting in Step 9
- ALWAYS understand each file before moving to the next
- If unsure about something, re-read the specific file

## Additional Resources

### Reference Files

- **`references/file-categories.md`** — File priority classification rules
- **`references/security-patterns.md`** — Security grep patterns and detection rules
- **`references/review-templates.md`** — Review posting templates (LGTM, changes requested, minor suggestions)
