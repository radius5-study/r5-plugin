# Verifying Information with Source Code

Since the target repository is open source, always verify Deepwiki information against the actual source code using `gh` CLI.

## Verification Workflow

1. **Get file path from Deepwiki**: Ask Deepwiki for specific file paths
   ```python
   ask_question(
       repoName="owner/repo",
       question="Where is the main implementation located? Provide the exact file path."
   )
   ```

2. **View actual source code with gh**: Use gh CLI to view the file on GitHub
   ```bash
   # View specific file
   gh api repos/owner/repo/contents/path/to/file.py | jq -r '.content' | base64 -d

   # Or view raw file directly
   curl -s https://raw.githubusercontent.com/owner/repo/main/path/to/file.py
   ```

3. **Search for specific functions/classes**:
   ```bash
   # Search code in repository
   gh api search/code -X GET -f q="repo:owner/repo function_name" | jq '.items[].path'

   # Get specific line ranges after finding the file
   gh api repos/owner/repo/contents/path/to/file.py | jq -r '.content' | base64 -d | head -100
   ```

4. **Check recent changes** (Deepwiki may be outdated):
   ```bash
   # View recent commits to a file
   gh api repos/owner/repo/commits -f path=path/to/file.py -f per_page=5 | jq '.[].commit.message'

   # View git blame for specific lines
   gh api repos/owner/repo/contents/path/to/file.py | jq -r '.content' | base64 -d
   ```

## Critical Verification Points

Always verify when:
- Implementation details seem unclear or contradictory
- File paths are mentioned (verify they exist and content matches)
- Function signatures or class definitions are described
- Version-specific behavior is discussed (check if it has changed)
- Edge cases or error handling is explained

## Complete Research with Verification Example

```python
# Step 1: Get information from Deepwiki
result = ask_question(
    repoName="owner/repo",
    question="Where is the main implementation? What classes and methods are involved?"
)

# Step 2: Verify with actual source code
# In terminal:
# gh api repos/owner/repo/contents/src/main.py | jq -r '.content' | base64 -d

# Step 3: Search for specific function definitions
# gh api search/code -X GET -f q="repo:owner/repo def process"
```

## Tips for Effective Research

1. **Ask specific questions**: Specific questions about features or files yield better answers than vague ones
2. **Trace execution flow**: Ask "how does X work" to understand execution flow
3. **Note file names**: Once implementation location is identified, note the file names
4. **Explore related features**: After understanding one feature, ask about related features to build a complete picture
5. **Always verify with source**: Use gh CLI to cross-check Deepwiki answers with actual code
