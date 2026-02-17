# Troubleshooting Guide

Common problems during Deepwiki research and their solutions.

---

## Problem 1: Deepwiki Returns Outdated Information

### Symptoms
```python
ask_question(repoName="owner/repo", question="Where is feature X implemented?")
# Response: "Implemented in src/old_location.py"
```

```bash
# But file doesn't actually exist
gh api repos/owner/repo/contents/src/old_location.py
# Error: Not Found
```

### Causes
- Deepwiki data is outdated
- File moved due to refactoring
- Feature consolidated into different file

### Solutions

#### Method 1: Find current location with code search
```bash
# Search by function or class name
gh api search/code -X GET -f q="repo:owner/repo FunctionName" | jq '.items[] | {path, name}'

# Broader search
gh api search/code -X GET -f q="repo:owner/repo feature_x in:file" | jq '.items[0:5] | .[] | .path'
```

#### Method 2: Track through commit history
```bash
# Check last commit for old file path
gh api repos/owner/repo/commits -f path=src/old_location.py -f per_page=1 | jq '.[0].commit | {message, date: .author.date}'

# Find file move commits
gh api repos/owner/repo/commits -f per_page=20 | jq '.[] | select(.commit.message | contains("move") or contains("refactor")) | {message: .commit.message, sha: .sha}'
```

#### Method 3: Check README and documentation
```bash
# Check README
gh api repos/owner/repo/readme | jq -r '.content' | base64 -d

# Check docs directory
gh api repos/owner/repo/contents/docs | jq '.[] | {name, path}'
```

---

## Problem 2: Repository Not Found

### Symptoms
```python
ask_question(repoName="owner/repo", question="How does it work?")
# Error: Repository not found
```

### Causes
- Repository name typo
- Private repository (Deepwiki doesn't support)
- Repository deleted/renamed
- Wrong owner name

### Solutions

#### Method 1: Verify correct repository name on GitHub
```bash
# Search with GitHub API
gh api search/repositories -X GET -f q="repo_name" | jq '.items[] | {full_name, description}'

# Find from organization's repository list
gh api orgs/organization-name/repos | jq '.[] | .full_name'
```

#### Method 2: For private repositories
```bash
# Private repositories require direct investigation with gh CLI, not Deepwiki
gh repo view owner/repo

# Check file structure
gh api repos/owner/repo/contents | jq '.[] | {name, type, path}'

# Read specific file
gh api repos/owner/repo/contents/README.md | jq -r '.content' | base64 -d
```

#### Method 3: Check for repository rename/move
```bash
# GitHub will show redirects
gh repo view old-owner/old-name
# If redirected, shows new name

# Find current location with search
gh api search/repositories -X GET -f q="old-name" | jq '.items[] | {full_name, description}'
```

---

## Problem 3: Difficult Investigation in Large Repositories

### Symptoms
- Deepwiki responses are vague
- Too many related files to narrow down
- Unclear where to start investigation

### Solutions

#### Method 1: Progressive approach
```python
# Step 1: Understand structure first
read_wiki_structure(repoName="large-org/large-repo")

# Step 2: Ask about specific main directory
ask_question(
    repoName="large-org/large-repo",
    question="What is the purpose of the src/core directory?"
)

# Step 3: Narrow down further
ask_question(
    repoName="large-org/large-repo",
    question="In src/core, where is the main execution logic?"
)
```

#### Method 2: Track from entry point
```bash
# Identify entry point from package.json or setup.py
gh api repos/owner/repo/contents/package.json | jq -r '.content' | base64 -d | jq '.main'

# Read entry point file
gh api repos/owner/repo/contents/src/index.js | jq -r '.content' | base64 -d
```

#### Method 3: Split investigation by directory
```python
# Investigate core features
ask_question(repoName="owner/repo", question="What does the src/core directory handle?")

# Investigate utils features
ask_question(repoName="owner/repo", question="What utilities are in src/utils?")

# Integrated understanding
ask_question(repoName="owner/repo", question="How do src/core and src/utils interact?")
```

---

## Problem 4: Vague/Unclear Responses

### Symptoms
Deepwiki responses like:
- "Implemented in several files"
- "Multiple modules are involved"
- No specific file paths included

### Causes
- Question too vague
- Feature distributed across multiple files
- Deepwiki data incomplete

### Solutions

#### Method 1: Make question more specific
```python
# ❌ Vague question
ask_question(repoName="owner/repo", question="How does authentication work?")

# ✅ Specific question
ask_question(
    repoName="owner/repo",
    question="Where is the login authentication logic implemented? What file contains the password verification function?"
)
```

#### Method 2: Split into multiple questions
```python
# Question 1: Entry point
ask_question(repoName="owner/repo", question="What is the main entry point for authentication?")

# Question 2: Specific processing
ask_question(repoName="owner/repo", question="How is password hashing performed in authentication?")

# Question 3: Data flow
ask_question(repoName="owner/repo", question="What is the data flow from login request to session creation?")
```

#### Method 3: Supplement with code search
```bash
# Search for related files by keyword
gh api search/code -X GET -f q="repo:owner/repo authentication" | jq '.items[0:10] | .[] | .path'

# Search by function name
gh api search/code -X GET -f q="repo:owner/repo def authenticate" | jq '.items[] | {path, name}'

# Search by class name
gh api search/code -X GET -f q="repo:owner/repo class Authenticator" | jq '.items[] | .path'
```

---

## Problem 5: Complex Commit History Makes Tracking Difficult

### Symptoms
- File moved/renamed multiple times
- Implementation heavily refactored
- Large discrepancy between Deepwiki info and current code

### Solutions

#### Method 1: Check change history with git blame
```bash
# Check file change history
gh api repos/owner/repo/commits -f path=src/main.py -f per_page=10 | jq '.[] | {message: .commit.message, date: .commit.author.date, sha: .sha}'

# Check diff for specific commit
gh api repos/owner/repo/commits/COMMIT_SHA | jq -r '.files[] | select(.filename == "src/main.py") | .patch'
```

#### Method 2: Investigate by tag/release
```bash
# Check release tags
gh api repos/owner/repo/tags | jq '.[] | {name, commit: .commit.sha}'

# Check file at specific version
gh api repos/owner/repo/contents/src/main.py?ref=v1.0.0 | jq -r '.content' | base64 -d
```

#### Method 3: Understand intent from PRs
```bash
# Check recently merged PRs
gh pr list --repo owner/repo --state merged --limit 20

# Check specific PR details
gh pr view 123 --repo owner/repo

# Check file changes in PR
gh pr diff 123 --repo owner/repo
```

---

## Problem 6: Difficult to Compare Multiple Similar Repositories

### Symptoms
- Want to know differences between fork source and fork
- Want to compare implementations across multiple frameworks

### Solutions

#### Method 1: Ask same question to multiple repositories
```python
# Repository 1
ask_question(
    repoName="original/repo",
    question="How is feature X implemented?"
)

# Repository 2 (fork)
ask_question(
    repoName="fork/repo",
    question="How is feature X implemented?"
)

# Compare responses to identify differences
```

#### Method 2: Direct comparison with gh CLI
```bash
# Get same file from both repositories
gh api repos/original/repo/contents/src/feature.py | jq -r '.content' | base64 -d > original_feature.py
gh api repos/fork/repo/contents/src/feature.py | jq -r '.content' | base64 -d > fork_feature.py

# Compare with diff
diff original_feature.py fork_feature.py
```

#### Method 3: Identify divergence point from commit history
```bash
# Recent commits from fork source
gh api repos/original/repo/commits -f per_page=5

# Recent commits from fork
gh api repos/fork/repo/commits -f per_page=5

# Check diff from specific commit
gh api repos/fork/repo/compare/COMMIT_SHA...HEAD
```

---

## Best Practices: Tips to Avoid Problems

### 1. Always include verification step
```python
# Deepwiki investigation
result = ask_question(repoName="owner/repo", question="Where is X?")

# Always verify with source code
# gh api repos/owner/repo/contents/path/from/deepwiki | jq -r '.content' | base64 -d
```

### 2. Make questions progressively specific
```python
# Level 1: Big picture
ask_question(repoName="owner/repo", question="What is the overall architecture?")

# Level 2: Component
ask_question(repoName="owner/repo", question="How does the authentication component work?")

# Level 3: Implementation details
ask_question(repoName="owner/repo", question="Where is the password hashing function implemented?")
```

### 3. Use gh CLI and Deepwiki together
```python
# Understand overview with Deepwiki
ask_question(repoName="owner/repo", question="Where is feature X?")

# Verify details with gh CLI
# gh api search/code -X GET -f q="repo:owner/repo feature_x"
# gh api repos/owner/repo/contents/path/to/file.py | jq -r '.content' | base64 -d
```

### 4. Fallback on errors
```bash
# Alternative methods when Deepwiki fails

# 1. Get clues from README
gh api repos/owner/repo/readme | jq -r '.content' | base64 -d

# 2. Check documentation
gh api repos/owner/repo/contents/docs | jq

# 3. Infer structure from package.json or setup.py
gh api repos/owner/repo/contents/package.json | jq -r '.content' | base64 -d

# 4. Search for information in issues or discussions
gh issue list --repo owner/repo --label "documentation"
```
