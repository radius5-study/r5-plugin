---
name: deepwiki-research
description: This skill should be used when the user asks to "research a GitHub repository", "investigate org/repo", "deepwiki research", "analyze repository implementation", "understand how X repo works", or provides an "owner/repo" format GitHub repository name for investigation. Use for researching any GitHub repository's implementation, codebase structure, or internal workings using Deepwiki MCP.
---

# GitHub Deepwiki Research

## Overview

Investigate any GitHub repository's implementation details using Deepwiki MCP. This skill enables research on undocumented internal workflows, execution patterns, and core functionalities across any public GitHub repository.

## Setup

This plugin automatically configures Deepwiki MCP for public repository research. No manual setup required.

**For private repositories:**

If you need to research private repositories, update `plugins/r5/.mcp.json` to include your API key:

```json
{
  "deepwiki": {
    "url": "https://mcp.devin.ai/mcp",
    "headers": {
      "Authorization": "Bearer ${DEEPWIKI_API_KEY}"
    }
  }
}
```

Then set the environment variable:
```bash
export DEEPWIKI_API_KEY="your-api-key-here"
```

See [Deepwiki MCP documentation](https://docs.devin.ai/work-with-devin/deepwiki-mcp) for API key setup.

## Triggers

Use this skill when user mentions any of the following:
- "deepwiki research"
- "investigate repo", "research repo", "analyze repo"
- "owner/repo" format (e.g., "facebook/react", "python/cpython")
- "how does X repository work"
- "understand implementation of"
- Comparing implementation with upstream

## When to Use

- Investigating feature implementations in a repository
- Understanding workflow or execution flow
- Researching patterns in a codebase
- Understanding internal processing mechanisms
- Locating specific functionality in a codebase
- Comparing implementation with upstream

## Workflow

### Step 1: Identify the target repository

Extract the repository name from user input. The format should be `owner/repo` (e.g., `facebook/react`, `python/cpython`, `Comfy-Org/ComfyUI`).

If user doesn't specify a repository, ask: "Which GitHub repository would you like to investigate? Please provide it in `owner/repo` format."

### Step 2: Understand what to investigate

Identify the specific feature, function, or behavior to understand. Formulate a clear question.

### Step 3: Research with Deepwiki MCP

**3 tools, use in order** — this sequence dramatically improves precision:

**Step 3a: Get topic list** (always start here for unfamiliar repos)
```python
read_wiki_structure(repoName="owner/repo")
# → Returns list of wiki topics (e.g., "Architecture", "Authentication", "Data Flow")
```

**Step 3b: Read the most relevant topic in full** (this is the key step)
```python
read_wiki_contents(repoName="owner/repo", topic="Architecture")
# → Returns comprehensive wiki page: accurate file paths, class names, data flow diagrams
# → Far more reliable than ask_question alone — use this before asking questions
```

**Step 3c: Ask follow-up questions** (for specifics not covered in the wiki page)
```python
ask_question(
    repoName="owner/repo",
    question="Your specific question about the implementation"
)
```

> **Why this order matters**: `read_wiki_contents` returns the full curated wiki page for a topic,
> giving far more accurate file paths and implementation details than RAG-based Q&A alone.
> Use it *before* `ask_question` to ground your follow-up questions in real context.

See [references/deepwiki-tools.md](references/deepwiki-tools.md) for detailed API reference.

### Step 4: Identify file paths from Deepwiki response

Extract specific file paths mentioned in the response (e.g., `src/index.js`, `lib/core.py`).

### Step 5: View actual source code with gh CLI (CRITICAL)

**Always verify Deepwiki information by viewing the actual source code.** Deepwiki may be outdated or incorrect.

```bash
# Step 5a: View the file identified in Step 4
gh api repos/owner/repo/contents/path/to/file.py | jq -r '.content' | base64 -d

# Step 5b: If you need to search for specific functions
gh api search/code -X GET -f q="repo:owner/repo function_name" | jq '.items[].path'

# Step 5c: View raw file directly (alternative)
curl -s https://raw.githubusercontent.com/owner/repo/main/path/to/file.py
```

### Step 6: Cross-reference and verify

Compare what Deepwiki provided with the actual source code:
- Are the file paths correct?
- Are the function names accurate?
- Is the implementation logic as described?
- Note any discrepancies

### Step 7: Repeat if needed

If the source code reveals related functions or files, repeat from Step 3.

## Important Notes

- **Never trust Deepwiki alone** - always verify with source code
- **Check recent commits** - Deepwiki may be outdated:
  ```bash
  gh api repos/owner/repo/commits -f path=path/to/file.py -f per_page=3
  ```
- **Start with specific questions** - vague questions yield vague answers
- **Always confirm repository name** - ensure you're researching the correct repo

## Resources

- **Detailed patterns**: See [references/research-patterns.md](references/research-patterns.md)
- **Verification guide**: See [references/verification.md](references/verification.md)
