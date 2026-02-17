# GitHub Repository Research Patterns

## Pattern 1: Investigate Specific Feature Implementation

```python
# Investigate workflow execution flow
ask_question(repoName="owner/repo", question="How is a workflow executed? Explain the execution flow.")

# Investigate module structure
read_wiki_structure(repoName="owner/repo")
```

## Pattern 2: Find Specific Files or Features

```python
# Find specific implementations
ask_question(repoName="owner/repo", question="Where is the main entry point? What files handle X functionality?")

# Find configuration handling
ask_question(repoName="owner/repo", question="How is configuration loaded and processed?")
```

## Pattern 3: Deep Dive into Specific Topics

```python
# Investigate architecture
ask_question(repoName="owner/repo", question="Explain the overall architecture and key components")

# Investigate specific mechanism
ask_question(repoName="owner/repo", question="How does the plugin/extension system work?")
```

## Common Research Topics

- **Workflow Execution**: Execution flow, dependency resolution, execution order
- **Module System**: Module registration, class structure, interface definitions
- **Data Loading**: Data loading processes, file handling
- **Internal Operations**: Core algorithms, data transformations
- **Extension/Plugin Systems**: How extensions are registered and executed
- **API Design**: Public API structure, request/response handling
- **Configuration**: Config loading, validation, defaults
- **Memory Management**: Resource management, caching strategies

## Example Queries

### Understanding Architecture

```python
ask_question(
    repoName="owner/repo",
    question="Explain the overall architecture. What are the main components and how do they interact?"
)
```

### Investigating Specific Implementation

```python
ask_question(
    repoName="owner/repo",
    question="Where is the main processing logic implemented? What classes and methods are involved?"
)
```

### Understanding Data Flow

```python
ask_question(
    repoName="owner/repo",
    question="Explain how data flows through the system from input to output"
)
```
