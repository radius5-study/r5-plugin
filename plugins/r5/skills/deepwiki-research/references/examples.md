# Deepwiki Research Examples

Real-world usage examples and best practices.

## Example 1: Investigating ComfyUI Custom Node Implementation

### Objective
Understand how custom nodes are registered and executed in ComfyUI

### Research Session

```python
# Step 1: Understand overall structure
read_wiki_structure(repoName="Comfy-Org/ComfyUI")

# Step 2: Ask about custom node system
ask_question(
    repoName="Comfy-Org/ComfyUI",
    question="How are custom nodes registered and loaded? What files handle custom node initialization?"
)
```

**Example Deepwiki Response:**
- Custom nodes are loaded from `custom_nodes/` directory
- `nodes.py` handles node registration
- Nodes are registered via `NODE_CLASS_MAPPINGS` dictionary

```bash
# Step 3: Verify with actual source code
gh api repos/Comfy-Org/ComfyUI/contents/nodes.py | jq -r '.content' | base64 -d | head -50

# Search for custom node loading logic
gh api search/code -X GET -f q="repo:Comfy-Org/ComfyUI NODE_CLASS_MAPPINGS" | jq '.items[] | {path, name}'
```

### Learnings
- Deepwiki's response was generally accurate, but viewing actual code revealed initialization flow details
- Custom node loading logic is actually in `folder_paths.py`

---

## Example 2: Investigating React Hook Implementation

### Objective
Understand the internal implementation of `useState`

### Research Session

```python
# Step 1: Locate useState implementation
ask_question(
    repoName="facebook/react",
    question="Where is the useState hook implemented? What files contain the core implementation?"
)
```

**Deepwiki Response:**
- Implemented in `packages/react-reconciler/src/ReactFiberHooks.js`
- Integrates with Fiber architecture

```bash
# Step 2: View actual file
gh api repos/facebook/react/contents/packages/react-reconciler/src/ReactFiberHooks.js | jq -r '.content' | base64 -d | grep -A 20 "function useState"

# Step 3: Check recent changes (Deepwiki may be outdated)
gh api repos/facebook/react/commits -f path=packages/react-reconciler/src/ReactFiberHooks.js -f per_page=5 | jq '.[].commit | {message, date: .author.date}'
```

### Learnings
- For large repositories like React, it's efficient to get an overview from Deepwiki first, then narrow down to specific files
- Checking commit history helps verify if implementation has changed

---

## Example 3: Investigating Next.js Server-Side Rendering

### Objective
Understand how Next.js SSR works

### Research Session

```python
# Step 1: Understand overall architecture
ask_question(
    repoName="vercel/next.js",
    question="Explain the overall server-side rendering architecture. What are the main components involved?"
)

# Step 2: Investigate getServerSideProps implementation
ask_question(
    repoName="vercel/next.js",
    question="How is getServerSideProps executed? What files handle the execution flow?"
)
```

```bash
# Step 3: View implementation files
gh api repos/vercel/next.js/contents/packages/next/server/render.tsx | jq -r '.content' | base64 -d | grep -B 5 -A 20 "getServerSideProps"

# Search for related files
gh api search/code -X GET -f q="repo:vercel/next.js getServerSideProps in:file" | jq '.items[0:5] | .[] | .path'
```

### Learnings
- For large repositories, understand the big picture first before diving into details
- Searching for related files helps see the complete implementation picture

---

## Example 4: Troubleshooting - Outdated Information

### Problem
Deepwiki returns outdated file paths

```python
ask_question(
    repoName="python/cpython",
    question="Where is the main Python interpreter loop implemented?"
)
```

**Deepwiki Response:**
- Implemented in `Python/ceval.c` (information from old version)

```bash
# Verify: Check if file exists
gh api repos/python/cpython/contents/Python/ceval.c 2>&1

# If error, use search to find current location
gh api search/code -X GET -f q="repo:python/cpython PyEval_EvalFrameEx" | jq '.items[0] | {path, name}'

# Or track changes from recent commits
gh api repos/python/cpython/commits -f path=Python/ceval.c -f per_page=1 | jq '.[0].commit.message'
```

### Solution
- Always verify file existence
- Use code search to find current location by function name
- Track refactoring/moves through commit history

---

## Best Practices

### 1. Drill down progressively
```python
# ❌ Bad: Jump straight to details
ask_question(repoName="owner/repo", question="Show me the exact implementation of function X")

# ✅ Good: Understand overview first
ask_question(repoName="owner/repo", question="What is the overall architecture?")
# Then dive into details
ask_question(repoName="owner/repo", question="Where is feature X implemented?")
```

### 2. Always verify with source code
```python
# Get information from Deepwiki
result = ask_question(repoName="owner/repo", question="Where is X implemented?")

# Always verify with gh CLI
# gh api repos/owner/repo/contents/path/to/file.py | jq -r '.content' | base64 -d
```

### 3. Ask specific questions
```python
# ❌ Vague: "How does this repo work?"
# ✅ Specific: "How is authentication handled? What files implement the login flow?"
```

### 4. Deepen understanding with multiple questions
```python
# Round 1: Big picture
ask_question(repoName="owner/repo", question="What is the main architecture?")

# Round 2: Specific component
ask_question(repoName="owner/repo", question="How does component X work?")

# Round 3: Related functionality
ask_question(repoName="owner/repo", question="How does X interact with Y?")
```

---

## Common Research Patterns

### Pattern 1: Understanding a New Repository
1. `read_wiki_structure` to understand overall structure
2. Ask about main components
3. Identify entry points
4. Investigate implementation details

### Pattern 2: Deep Dive into Specific Feature
1. Ask where feature is implemented
2. Get file paths
3. View source code
4. Investigate related files

### Pattern 3: Bug Investigation & Debugging Support
1. Ask about problem area
2. Investigate error handling
3. Check related test code
4. Review recent changes
