# Deepwiki MCP Tools Reference

Detailed reference for Deepwiki MCP tools.

## Overview

Deepwiki MCP provides the following tools for investigating GitHub repositories:

1. `read_wiki_structure` - Get list of wiki topics for a repository
2. `read_wiki_contents` - Read full wiki page for a specific topic (**highest accuracy**)
3. `ask_question` - Ask targeted questions about a repository

**Recommended order**: `read_wiki_structure` → `read_wiki_contents` → `ask_question`

---

## Tool 1: read_wiki_structure

### Description
Get the list of wiki topics for a repository. Use this first to discover which topics exist before reading content.

### Parameters

```python
read_wiki_structure(
    repoName: str      # Required: Repository name in "owner/repo" format
)
```

### Return Value

A list of topic names (e.g., `["Overview", "Architecture", "Authentication", "Data Flow", "API Reference"]`).

### Usage

```python
# Always start here for unfamiliar repos
read_wiki_structure(repoName="Comfy-Org/ComfyUI")
# → Pick the most relevant topic(s) to read with read_wiki_contents
```

---

## Tool 2: read_wiki_contents

### Description
Read the **full wiki page** for a specific topic. This is the highest-accuracy tool — it returns curated documentation with precise file paths, class names, and implementation details, not RAG-generated answers.

### Parameters

```python
read_wiki_contents(
    repoName: str,     # Required: Repository name in "owner/repo" format
    topic: str         # Required: Topic name from read_wiki_structure output
)
```

### Return Value

Full wiki page content:
- Accurate file paths and directory structure
- Class/function names with context
- Architecture diagrams (as text/ASCII)
- Implementation details and data flow

### Why this matters

| Tool | Source | Accuracy |
|------|--------|----------|
| `ask_question` | RAG over indexed content | Medium — depends on question phrasing |
| `read_wiki_contents` | Curated wiki page | **High** — complete, structured information |

### Usage Examples

```python
# Step 1: Discover topics
read_wiki_structure(repoName="facebook/react")
# Returns: ["Overview", "Fiber Architecture", "Reconciler", "Hooks", ...]

# Step 2: Read the relevant topic in full
read_wiki_contents(repoName="facebook/react", topic="Fiber Architecture")
# Returns: full page with accurate file paths, class names, and flow diagrams

# Step 3: Ask follow-up questions if needed
ask_question(
    repoName="facebook/react",
    question="How does the Fiber scheduler prioritize work units?"
)
```

### When to Use

- ✅ **Use when**: You found a relevant topic in `read_wiki_structure` output
- ✅ **Use when**: You need accurate file paths before running `gh` CLI verification
- ✅ **Use when**: You want the full picture before drilling into specifics
- ❌ **Skip when**: No relevant topic exists in the structure (fall back to `ask_question`)

---

## Tool 3: ask_question

### Description
Ask specific questions about a GitHub repository to investigate implementation details.

### Parameters

```python
ask_question(
    repoName: str,     # Required: Repository name in "owner/repo" format
    question: str      # Required: Question about what you want to investigate
)
```

#### repoName
- **Format**: `owner/repo` (e.g., `facebook/react`, `vercel/next.js`)
- **Required**: Yes
- **Examples**:
  - `"Comfy-Org/ComfyUI"`
  - `"python/cpython"`
  - `"microsoft/TypeScript"`

#### question
- **Format**: Natural language question
- **Required**: Yes
- **Recommended**: Specific and clear questions
- **Good Examples**:
  - `"Where is the main workflow execution logic implemented?"`
  - `"How are custom plugins registered and loaded?"`
  - `"What files handle user authentication?"`
- **Bad Examples**:
  - `"How does this work?"` (too vague)
  - `"Tell me everything"` (too broad)

### Return Value

Returns text format with:
- Answer to the question
- Related file paths
- Implementation overview
- Code snippets (when applicable)

### Usage Examples

```python
# Example 1: Locate implementation
ask_question(
    repoName="Comfy-Org/ComfyUI",
    question="Where is the node execution logic implemented? What files are involved?"
)

# Example 2: Understand architecture
ask_question(
    repoName="facebook/react",
    question="Explain the React Fiber architecture. What are the main components?"
)

# Example 3: Investigate specific feature behavior
ask_question(
    repoName="vercel/next.js",
    question="How does Next.js handle image optimization? What is the processing flow?"
)

# Example 4: Understand data flow
ask_question(
    repoName="django/django",
    question="How does Django's ORM execute queries? Explain the data flow from model to database."
)
```

### Limitations

- **Freshness**: Deepwiki information is not always up-to-date. Always verify with actual source code using gh CLI
- **Accuracy**: File paths and function names may be outdated
- **Scope**: For very large repositories, answers may be limited to portions
- **Access**: Only public repositories are supported

### Best Practices

1. **Ask specific questions**
   ```python
   # ❌ Bad example
   ask_question(repoName="owner/repo", question="How does it work?")

   # ✅ Good example
   ask_question(repoName="owner/repo", question="How is the authentication middleware implemented?")
   ```

2. **Split questions**
   ```python
   # Split large questions to deepen understanding progressively
   # Step 1: Big picture
   ask_question(repoName="owner/repo", question="What is the overall architecture?")

   # Step 2: Specific component
   ask_question(repoName="owner/repo", question="How does the routing system work?")
   ```

3. **Always verify**
   ```python
   # Get information from Deepwiki
   result = ask_question(repoName="owner/repo", question="Where is X implemented?")

   # Verify with actual source code (using Bash tool)
   # gh api repos/owner/repo/contents/path/to/file.py | jq -r '.content' | base64 -d
   ```

---

## Tool 2: read_wiki_structure

### Description
Get overall repository structure and documentation organization. Effective for understanding overview of unfamiliar repositories.

### Parameters

```python
read_wiki_structure(
    repoName: str      # Required: Repository name in "owner/repo" format
)
```

#### repoName
- **Format**: `owner/repo` (e.g., `facebook/react`, `python/cpython`)
- **Required**: Yes

### Return Value

Repository structure information:
- Main directory structure
- Documentation organization
- Overview of important files

### Usage Examples

```python
# Example 1: Understand overall structure of new repository
read_wiki_structure(repoName="Comfy-Org/ComfyUI")

# Example 2: Understand structure of large project
read_wiki_structure(repoName="microsoft/vscode")

# Example 3: Understand framework organization
read_wiki_structure(repoName="django/django")
```

### When to Use

- ✅ **Use when**:
  - First time investigating a repository
  - Large, complex structure repository
  - Unsure where to start investigation

- ❌ **Not needed when**:
  - Already understand repository structure
  - Only investigating specific file/feature
  - Small repository

### Best Practices

```python
# Example workflow: Large repository investigation

# Step 1: Understand structure first
structure = read_wiki_structure(repoName="microsoft/TypeScript")

# Step 2: Ask specific questions based on structure
ask_question(
    repoName="microsoft/TypeScript",
    question="Based on the structure, where is the type checker implemented?"
)

# Step 3: Verify with actual source code
# gh api repos/microsoft/TypeScript/contents/src/compiler/checker.ts | jq -r '.content' | base64 -d
```

---

## Effective Tool Selection

### Scenario 1: First-time Repository Investigation

```python
# 1. Understand overall structure
read_wiki_structure(repoName="owner/repo")

# 2. Ask about areas of interest
ask_question(repoName="owner/repo", question="How does feature X work?")

# 3. Verify with source code
# gh api repos/owner/repo/contents/path/to/file.py | jq -r '.content' | base64 -d
```

### Scenario 2: Investigating Specific Feature (Structure Already Known)

```python
# Skip structure if already known, start with direct question
ask_question(
    repoName="owner/repo",
    question="Where is the authentication system implemented?"
)

# Verify with source code
# gh api repos/owner/repo/contents/auth/main.py | jq -r '.content' | base64 -d
```

### Scenario 3: Investigating Multiple Related Features

```python
# 1. First question
ask_question(repoName="owner/repo", question="How is data validated?")

# 2. Related question
ask_question(repoName="owner/repo", question="How does validation interact with the database layer?")

# 3. Dive deeper
ask_question(repoName="owner/repo", question="What error handling is used in validation?")
```

---

## Important Notes

### Always Verify

Deepwiki is very useful, but always verify with actual source code for these reasons:

1. **Information freshness**: Deepwiki data may be outdated
2. **File moves**: File paths may have changed due to refactoring
3. **Implementation changes**: Feature implementation methods may have changed

```bash
# Verification template

# 1. Verify file existence
gh api repos/owner/repo/contents/path/to/file.py

# 2. View contents
gh api repos/owner/repo/contents/path/to/file.py | jq -r '.content' | base64 -d

# 3. Check recent changes
gh api repos/owner/repo/commits -f path=path/to/file.py -f per_page=3

# 4. Search for function/class
gh api search/code -X GET -f q="repo:owner/repo ClassName" | jq '.items[].path'
```

### Private Repositories

Deepwiki only supports public repositories. For private repository investigation, use gh CLI directly.
