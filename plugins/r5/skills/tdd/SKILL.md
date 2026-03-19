---
name: tdd
description: >
  Use this skill whenever the user wants to implement something using TDD (Test-Driven Development),
  mentions "Red Green Refactor", says "テスト駆動", "テスト書いて", "TDDで実装", "テストファースト",
  "test-driven", or asks to write a test for a function that doesn't exist yet.
  This skill enforces a strict type-first, stub-first discipline:
  types and stubs must exist before any test is written.
  Invoke this skill even if the user just says "TDDで" or "write a test for X" —
  the skill will handle the full Red → Green → Refactor cycle.
---

# TDD Skill — Red Green Refactor

This skill runs one complete TDD cycle (Red → Green → Refactor) per function/method.
Multiple functions are handled by spawning parallel sub-agents.

## Core Philosophy

- **Types before tests.** A function signature (name, parameter types, return type) must be fully written before any test touches it.
- **Stubs before Red.** A stub is a valid, runnable no-op — it compiles/parses without error. "The function doesn't exist" is never a valid Red state; that's a build error, not a test failure.
- **Red is a test that runs and fails.** Not a compile error. Not a missing import. A real assertion that evaluates to false.
- **Green is the minimum.** Write just enough implementation to make the failing tests pass — nothing more.
- **Refactor via /simplify.** Once Green, delegate cleanup to the `/simplify` skill.

---

## Step 0: Read Project Config

Before anything else, read `CLAUDE.md` (and any rules/settings files) to discover:
- Test runner and command (e.g., `npx vitest run`, `pytest`)
- File naming conventions (e.g., `*.test.ts`, `test_*.py`)
- Source directory layout
- Any project-specific type conventions

---

## Step 1: Parse Intent

Extract from the user's natural language input:
- **What**: the behavior to implement (e.g., "calculate the total price including tax")
- **Where**: target file and/or module (ask if unclear)
- **Constraints**: edge cases, error conditions, special types mentioned

If multiple functions are described, identify them all now. You will handle them in parallel (see Multi-Method below).

---

## Step 2: Define Types & Signature

Write the function/method signature with full type annotations to the target file.
Do NOT write an implementation yet — only the signature.

The form this takes depends on the language:
- Statically typed languages: write the full typed signature
- Dynamically typed languages with annotation support (Python, TypeScript): use type hints/annotations
- Dynamically typed without annotations: document the expected shape in a docstring or comment, and be explicit in the test about what types are expected

If the return type is genuinely unknown at this stage, discuss with the user before proceeding.
Types must always be explicit — vague types (`any`, `object`, untyped wildcards) are not acceptable substitutes.

---

## Step 3: Create the Stub

Replace the bare signature with a valid stub — a function body that:
- Compiles/parses/imports without errors
- Does NOT implement the behavior (throw/raise a "not implemented" error, or return a clearly wrong default)
- Satisfies the type-checker if one is configured

The stub's purpose is to make the test *runnable* — it will fail, but it won't crash before reaching the assertion.

After writing the stub, verify it loads cleanly (dry-run, compile check, or import check depending on the language).

---

## Step 4: Red — Write Failing Tests

Write unit tests that:
- Import/reference the stub
- Assert the expected behavior described in Step 1
- Cover at least the happy path and one edge case

Then **run the test runner** and confirm the tests actually fail.
A real Red state means: the test reaches the assertion and fails — not a compile error, not a missing import, not a crash before the assertion.

If the tests don't even run (import error, syntax error, etc.), fix that first. That's not Red yet.

Use the test file location and naming convention from the project config (CLAUDE.md / rules). If not specified, follow the language/framework conventions.

---

## Step 5: Green — Minimal Implementation

Write the smallest implementation that makes the failing tests pass.
"Minimal" means: if removing a line would cause a test to fail, keep it; otherwise, remove it.

Then **run the test runner** and confirm all tests pass:
```
PASS src/pricing.test.ts
  ✓ calculateTotal returns correct total with tax (3ms)
  ✓ calculateTotal handles zero tax rate (1ms)
```

### If tests still fail after implementation:

Retry up to 2 times, making targeted changes based on the failure output.
If still failing after 2 retries, **stop and report to the user**:

```
Green failed after 2 retries. Failure:
  <paste actual test output>

This likely indicates a design issue in the stub or type signature —
for example, the return type or parameter contract may need revisiting.
Please review the stub and let me know how to proceed.
```

---

## Step 6: Refactor

Once Green, invoke `/simplify` on the implementation file.
Do not manually refactor — delegate entirely.

---

## Multi-Method

When the user describes multiple functions in one request:

1. **Stub phase (parallel):** Create type definitions and stubs for all functions simultaneously. Stubs don't depend on each other.

2. **Green phase (ordered):** Identify dependency relationships (does function A call function B?).
   - Independent functions: spawn parallel sub-agents, one per function
   - Dependent functions: run Green for B first, then A

Each sub-agent receives:
- The specific function to implement
- The stub already written
- The test file path
- The test runner command

---

## Reference files

See `references/examples.md` for concrete worked examples in TypeScript (vitest) and Python (pytest).
