---
name: pr-review
description: This skill should be used when the user asks to "review a PR", "review pull request", "check this PR", "look at this PR", "is this PR ready to merge", "PRレビューして", "PRをレビュー", "PR見て", "コードレビュー", or when performing automated or manual code reviews on GitHub pull requests. Provides a structured, incremental review workflow with security checks, file prioritization, and merge readiness assessment.
disable-model-invocation: true
---

# PR Review Workflow

## Hard Rules (MUST follow — violation of ANY rule is a critical failure)

1. **No Low severity reports.** Do NOT report style nits, type annotation improvements, debug statements, import order, documentation suggestions, or any Low severity finding. This applies to your own findings AND all agent outputs. If unsure, don't report it.
2. **Always include AI Fix Prompt.** Every review with issues MUST end with a `### 🤖 AI Fix Prompt` section per **`references/review-templates.md`**.
3. **Always post via `gh pr review`.** Never just output text. Always run the `gh pr review` command.
4. **Never fetch full diff if >300 lines.** Review file by file with `gh pr diff <PR_NUMBER> -- path/to/file`.
5. **Never review lock files line-by-line.** Acknowledge their presence briefly.
6. **Strictly follow the output templates.** The review body MUST use the exact template structure from **`references/review-templates.md`**. Do NOT invent your own format. The body MUST start with one of: `## ✅ LGTM`, `## ⚠️ Changes Requested`, `## 💬 Review Complete`, `## ⏭️ Auto Review Skipped`. Do NOT use `# Issue 1`, `# Issue 2`, numbered issue headers, before/after code diffs, or any other custom format.
7. **AI Fix Prompt MUST be in English.** Even if the rest of the review is in Japanese, the AI Fix Prompt content (the text inside the code block) MUST be written in English ONLY. This ensures compatibility with AI agents that may not understand Japanese.

## Review Steps

### 1. Gather Context

Read the repository's `CLAUDE.md`, then collect PR metadata:

```bash
gh pr view <PR_NUMBER> --json title,body,baseRefName,headRefName,files,commits
gh pr diff <PR_NUMBER> --name-only
gh pr view <PR_NUMBER> --json additions,deletions | jq '.additions + .deletions'
```

**Diff size tiers:**
- **>10,000 lines** → Skip review, post skip notice from **`references/review-templates.md`**
- **>300 lines or >10 files** → Review file by file (see Hard Rule 4)
- **≤300 lines and ≤10 files** → Review full diff at once

**Check for previous review:** Try to load the review cache artifact, then check for previous review content on GitHub:

**Check for previous review:**

```bash
# CI: read cache restored by actions/cache
cat .claude-reviews/pr-<PR_NUMBER>.json 2>/dev/null

# Fallback: get previous review from GitHub
gh pr view <PR_NUMBER> --json comments,reviews --jq '
  [(.comments[]? | select(.body | contains("Reviewed by Claude")) | {body: .body, at: .createdAt}),
   (.reviews[]? | select(.body | contains("Reviewed by Claude")) | {body: .body, at: .createdAt})]
  | sort_by(.at) | last | .body'
```

If a previous review exists: avoid repeating the same feedback, focus only on new changes.

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

### 3.5. Run Simplification Analysis (conditional)

**Only run this step when NO Critical or High severity issues were found in Steps 2–3.**

Run the **code-simplifier** agent against source code files changed in the PR. The goal is to identify opportunities for improving clarity, reducing complexity, and removing unnecessary abstractions — without changing behavior.

**Scope:**
- Only analyze HIGH PRIORITY files (source code) from **`references/file-categories.md`**
- Skip test files, config files, and lock files
- Focus on code added or modified in this PR, not pre-existing code

**How to use results:**
- Simplification suggestions are **always non-blocking** — they NEVER affect merge readiness
- Include up to 3 actionable suggestions in the review under `### 💡 Simplification Suggestions`
- Add simplification instructions to the AI Fix Prompt section so the author can apply them with one click
- If code-simplifier finds nothing meaningful, omit the section entirely

### 4. Post Review

Determine merge readiness and post via `gh pr review` using templates from **`references/review-templates.md`**:

- **No Critical/High issues** → `gh pr review --approve` (LGTM)
- **Critical/High issues found** → `gh pr review --request-changes`
- **Only Medium suggestions** → `gh pr review --comment` then `--approve`

**Required template structure (Hard Rule 6):**

For changes requested, the body MUST follow this skeleton exactly:

```
## ⚠️ Changes Requested

**Summary**: [One sentence]

**Assessment**: [Why not ready]

### Issues Found
[Bulleted list with file:line references and severity]

### 🤖 AI Fix Prompt
<details>
<summary>Copy this prompt to your AI agent to fix all issues at once</summary>

````
Fix the following issues in this repository:

In `@path/to/file`:
- Line N: [What is wrong and how to fix it]
````

</details>

---
*Reviewed by Claude*
```

Populate the `### 🤖 AI Fix Prompt` section with self-contained fix instructions (exact file paths, line numbers, what to change and why). Use 4 backticks (` ```` `) for the outer code fence so inner code examples with 3 backticks don't break rendering. (Hard Rule 2)

**NEVER DO THIS — the following formats are WRONG:**

- ❌ `# Issue 1: ...` / `# Issue 2: ...` — numbered issue headers
- ❌ Showing "変更前" / "変更後" / "before" / "after" code diffs in the review body
- ❌ Listing file paths as section headers (`## path/to/file.ts`)
- ❌ Any format that doesn't start with `## ✅`, `## ⚠️`, or `## 💬`
