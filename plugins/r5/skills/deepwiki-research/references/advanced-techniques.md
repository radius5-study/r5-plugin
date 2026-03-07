# Advanced Research Techniques

Advanced techniques for more efficient and effective Deepwiki research.

---

## Technique 1: Cross-Repository Investigation

### Use Cases
- Comparing implementations across frameworks (React vs Vue vs Svelte, etc.)
- Understanding differences between fork source and fork
- Comparing alternative library implementations

### Implementation Pattern

```python
# Define repository list
repos = [
    "facebook/react",
    "vuejs/core",
    "sveltejs/svelte"
]

# Ask same question to each repository
for repo in repos:
    ask_question(
        repoName=repo,
        question="How is component state management implemented?"
    )
    # Compare each response to understand characteristics
```

### Comparison Points
- Architectural differences
- Performance optimization approaches
- API design philosophy
- File organization differences

### Verification Method
```bash
# Get same feature implementation from each repository
gh api repos/facebook/react/contents/packages/react/src/ReactHooks.js | jq -r '.content' | base64 -d > react_hooks.js
gh api repos/vuejs/core/contents/packages/reactivity/src/ref.ts | jq -r '.content' | base64 -d > vue_ref.ts

# Compare with diff tool
diff react_hooks.js vue_ref.ts
```

---

## Technique 2: Investigating Specific Versions/Branches

### Use Cases
- Investigating when breaking changes were introduced
- Understanding specific version implementation
- Early investigation of beta version new features

### Implementation Methods

#### Method 1: Investigate from tags/releases
```bash
# Check available versions
gh api repos/owner/repo/tags | jq '.[] | {name, commit: .commit.sha}'

# Get file at specific version
gh api repos/owner/repo/contents/src/main.py?ref=v2.0.0 | jq -r '.content' | base64 -d
```

#### Method 2: Investigate differences between branches
```bash
# List branches
gh api repos/owner/repo/branches | jq '.[] | .name'

# Compare main and beta
gh api repos/owner/repo/compare/main...beta | jq -r '.files[] | {filename, status, changes}'

# Check specific file in beta
gh api repos/owner/repo/contents/src/new_feature.py?ref=beta | jq -r '.content' | base64 -d
```

#### Method 3: Track changes through commit history
```bash
# Extract commits from specific period
gh api repos/owner/repo/commits -f since=2024-01-01 -f until=2024-12-31 -f per_page=100 | jq '.[] | {date: .commit.author.date, message: .commit.message}'

# Change history for specific file
gh api repos/owner/repo/commits -f path=src/critical_file.py -f per_page=20 | jq '.[] | {date: .commit.author.date, message: .commit.message, sha: .sha}'
```

### Combining with Deepwiki
```python
# Understand latest version implementation
ask_question(repoName="owner/repo", question="How is feature X implemented in the latest version?")

# Then compare with old versions
# gh api repos/owner/repo/contents/src/feature.py?ref=v1.0.0 | jq -r '.content' | base64 -d
# gh api repos/owner/repo/contents/src/feature.py?ref=v2.0.0 | jq -r '.content' | base64 -d
```

---

## Technique 3: Advanced gh CLI Usage

### Advanced Code Search

```bash
# 1. Search limited to specific language
gh api search/code -X GET -f q="repo:owner/repo language:python authenticate" | jq '.items[] | {path, name}'

# 2. Search by file path pattern
gh api search/code -X GET -f q="repo:owner/repo path:src/core/ filename:*.py" | jq '.items[] | .path'

# 3. Regex-style search
gh api search/code -X GET -f q="repo:owner/repo /def.*authenticate/" | jq '.items[0:5] | .[] | {path, name}'

# 4. Exclusion patterns
gh api search/code -X GET -f q="repo:owner/repo authenticate NOT test" | jq '.items[] | .path'

# 5. Multiple condition combinations
gh api search/code -X GET -f q="repo:owner/repo language:typescript path:src/ react" | jq '.items[] | {path, name}'
```

### Insights from PRs & Issues

```bash
# 1. Search PRs related to specific feature
gh pr list --repo owner/repo --search "feature-name" --state all

# 2. Check PR file changes
gh pr diff 123 --repo owner/repo | head -100

# 3. Understand implementation intent from review comments
gh pr view 123 --repo owner/repo --comments

# 4. Understand background from related issues
gh issue list --repo owner/repo --search "feature-name"

# 5. Check issue-commit links
gh issue view 456 --repo owner/repo
```

### Deep Dive into Commit Details

```bash
# 1. Check all changes in specific commit
gh api repos/owner/repo/commits/COMMIT_SHA | jq '.files[] | {filename, additions, deletions, changes}'

# 2. Extract patterns from commit messages
gh api repos/owner/repo/commits -f per_page=100 | jq '.[] | .commit.message' | grep -i "refactor"

# 3. Track specific author's commits
gh api repos/owner/repo/commits -f author="author@email.com" | jq '.[] | {message: .commit.message, date: .commit.author.date}'
```

---

## Technique 4: Efficient Investigation of Large Repositories

### Strategy 1: Top-Down Approach

```python
# Step 1: Understand overall structure
read_wiki_structure(repoName="large-org/monorepo")

# Step 2: Read the most relevant topic in full
read_wiki_contents(repoName="large-org/monorepo", topic="Architecture")

# Step 3: Narrow down with targeted questions
ask_question(repoName="large-org/monorepo", question="How does packages/core/src/engine work?")
```

### Strategy 2: Track from Entry Point

```bash
# Identify entry point from package.json or setup.py
gh api repos/owner/repo/contents/package.json | jq -r '.content' | base64 -d | jq '{main, exports, bin}'

# Read entry point file
gh api repos/owner/repo/contents/dist/index.js | jq -r '.content' | base64 -d | head -50

# Track imported modules
gh api search/code -X GET -f q="repo:owner/repo import from" | jq '.items[0:10] | .[] | .path'
```

### Strategy 3: Understand from Tests

```bash
# Search for test files
gh api repos/owner/repo/contents/tests | jq '.[] | select(.name | endswith(".test.js")) | .path'

# Read test files to understand usage examples
gh api repos/owner/repo/contents/tests/feature.test.js | jq -r '.content' | base64 -d

# Reverse-lookup implementation from tests
# Search for implementation using function names from tests
gh api search/code -X GET -f q="repo:owner/repo functionNameFromTest" | jq '.items[] | .path'
```

---

## Technique 5: Tracking Dependencies

### Approach 1: Track import/require

```bash
# Extract imports from file
gh api repos/owner/repo/contents/src/main.js | jq -r '.content' | base64 -d | grep -E "import|require"

# Search for usage locations of specific module
gh api search/code -X GET -f q="repo:owner/repo import.*from.*module-name" | jq '.items[] | .path'
```

### Approach 2: Understand dependencies from package.json

```bash
# Check dependencies
gh api repos/owner/repo/contents/package.json | jq -r '.content' | base64 -d | jq '{dependencies, devDependencies}'

# Search where specific dependency is used
gh api search/code -X GET -f q="repo:owner/repo library-name" | jq '.items[0:10] | .[] | .path'
```

### Approach 3: Ask Deepwiki about dependencies

```python
ask_question(
    repoName="owner/repo",
    question="What external libraries does the authentication system depend on? How are they used?"
)

# Identify dependency libraries from response and check usage locations
# gh api search/code -X GET -f q="repo:owner/repo library-name"
```

---

## Technique 6: Performance Optimization Investigation

### Investigation Perspectives

```python
# 1. Investigate caching strategies
ask_question(
    repoName="owner/repo",
    question="What caching strategies are used? How is cache invalidation handled?"
)

# 2. Investigate memory management
ask_question(
    repoName="owner/repo",
    question="How is memory managed? Are there any pooling or reuse mechanisms?"
)

# 3. Investigate concurrent processing
ask_question(
    repoName="owner/repo",
    question="How is concurrency handled? What patterns are used for parallel processing?"
)
```

### Check Benchmark Tests

```bash
# Search for benchmark files
gh api search/code -X GET -f q="repo:owner/repo benchmark" | jq '.items[] | .path'

# Check performance tests
gh api repos/owner/repo/contents/benchmarks/performance.js | jq -r '.content' | base64 -d
```

---

## Technique 7: Security Perspective Investigation

### Authentication/Authorization Investigation

```python
# Understand authentication flow
ask_question(
    repoName="owner/repo",
    question="How is user authentication implemented? What libraries are used for password hashing?"
)

# Understand authorization logic
ask_question(
    repoName="owner/repo",
    question="How is authorization checked? Where are permission checks performed?"
)
```

### Check Security-Related Files

```bash
# Search for security-related files
gh api search/code -X GET -f q="repo:owner/repo security OR auth OR crypto" | jq '.items[0:10] | .[] | {path, name}'

# Check handling of environment variables and secrets
gh api search/code -X GET -f q="repo:owner/repo process.env" | jq '.items[] | .path'
```

---

## Technique 8: Visualizing Data Flow

### Step-by-Step Tracking

```python
# Step 1: Identify entry point
ask_question(repoName="owner/repo", question="What is the entry point for user requests?")

# Step 2: Understand middleware layer
ask_question(repoName="owner/repo", question="What middleware is applied to requests?")

# Step 3: Understand business logic layer
ask_question(repoName="owner/repo", question="How is business logic processed?")

# Step 4: Understand data access layer
ask_question(repoName="owner/repo", question="How is data persisted and retrieved?")

# Step 5: Understand response generation
ask_question(repoName="owner/repo", question="How are responses formatted and sent?")
```

### Implementation Verification

```bash
# Check files for each layer
gh api repos/owner/repo/contents/src/middleware/auth.js | jq -r '.content' | base64 -d
gh api repos/owner/repo/contents/src/services/user.js | jq -r '.content' | base64 -d
gh api repos/owner/repo/contents/src/models/user.js | jq -r '.content' | base64 -d
```

---

## Technique 9: Investigating Refactoring History

### Track Large Changes

```bash
# Search for commits containing "refactor"
gh api repos/owner/repo/commits -f per_page=50 | jq '.[] | select(.commit.message | contains("refactor")) | {message: .commit.message, sha: .sha, date: .commit.author.date}'

# Check changes in specific refactoring commit
gh api repos/owner/repo/commits/COMMIT_SHA | jq '.files[] | {filename, status, additions, deletions}'

# Understand refactoring background from PRs
gh pr list --repo owner/repo --search "refactor" --state merged
```

### Combine with Deepwiki for Understanding

```python
# Understand current implementation
ask_question(repoName="owner/repo", question="How is feature X currently implemented?")

# Compare with past implementation
# gh api repos/owner/repo/contents/src/feature.py?ref=COMMIT_BEFORE_REFACTOR | jq -r '.content' | base64 -d
# gh api repos/owner/repo/contents/src/feature.py?ref=COMMIT_AFTER_REFACTOR | jq -r '.content' | base64 -d
```

---

## Technique 10: Documentation-Driven Investigation

### Start with Documentation

```bash
# Check documentation directory
gh api repos/owner/repo/contents/docs | jq '.[] | {name, path}'

# Read main documentation
gh api repos/owner/repo/contents/docs/architecture.md | jq -r '.content' | base64 -d

# Understand development guide from CONTRIBUTING.md
gh api repos/owner/repo/contents/CONTRIBUTING.md | jq -r '.content' | base64 -d
```

### Verify Documentation-Code Consistency

```python
# Verify documented content with Deepwiki
ask_question(
    repoName="owner/repo",
    question="According to the docs, feature X should work like Y. Where is this implemented?"
)

# Verify implementation
# gh api repos/owner/repo/contents/src/feature.py | jq -r '.content' | base64 -d
```

---

## Summary: Efficient Investigation Workflow

### Recommended Flow

```python
# 1. Get topic list
read_wiki_structure(repoName="owner/repo")

# 2. Read the most relevant topic in full (KEY STEP — highest accuracy)
read_wiki_contents(repoName="owner/repo", topic="Most Relevant Topic")

# 3. Ask follow-up questions for specifics not in the wiki page
ask_question(repoName="owner/repo", question="Specific follow-up question")

# 4. Always verify with gh CLI using file paths from steps 2-3
# gh api repos/owner/repo/contents/path/to/file | jq -r '.content' | base64 -d

# 5. Track related files
# gh api search/code -X GET -f q="repo:owner/repo related_function"

# 6. Understand background from PRs and issues
# gh pr list --repo owner/repo --search "feature-name"

# 7. Compare with past versions as needed
# gh api repos/owner/repo/contents/file?ref=v1.0.0
```

### Time Efficiency Tips

1. **Parallel investigation**: Ask multiple questions simultaneously
2. **Use caching**: Save locally fetched files once
3. **Narrow searches**: Search with specific keywords from the start
4. **Understand from tests**: Test code is good documentation for implementation
5. **Use community**: Issues and Discussions are valuable information sources
