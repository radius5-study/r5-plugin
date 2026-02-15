# File Priority Categories

Classify changed files into the following priority levels for review ordering.

## HIGH PRIORITY — Source Code

Review these first. These files contain the core logic changes.

| Pattern | Language |
|---------|----------|
| `*.ts`, `*.tsx` | TypeScript (primary) |
| `*.js`, `*.jsx` | JavaScript |
| `*.py` | Python |
| `*.go` | Go |
| `*.java` | Java |
| `*.rb` | Ruby |
| `*.rs` | Rust |
| `*.cpp`, `*.c`, `*.h` | C/C++ |

### Copainter-Specific High Priority

- `client-app/src/app/**/_actions/*.ts` — Server actions (check auth, validation)
- `firebase/functions/src/*.ts` — Cloud Functions (check error handling, triggers)
- `client-app/src/lib/**/*.ts` — Shared libraries (check for breaking changes)
- `client-app/src/components/**/*.tsx` — Shared components (check prop changes)

## MEDIUM PRIORITY — Tests

Review after source code. Verify tests match the code changes.

| Pattern | Type |
|---------|------|
| `*.test.ts`, `*.test.tsx` | Vitest tests |
| `*.spec.ts`, `*.spec.tsx` | Spec files |
| `*test*.py` | Python tests |
| `*_test.go` | Go tests |

## MEDIUM PRIORITY — Configuration

Check for breaking changes in configuration files.

| Pattern | Type |
|---------|------|
| `*.yaml`, `*.yml` | YAML config |
| `*.json` | JSON config (not lock files) |
| `*.toml` | TOML config |
| `tsconfig*.json` | TypeScript config |
| `next.config.*` | Next.js config |
| `biome.json` | Linter config |
| `.github/workflows/*.yml` | CI/CD |

## LOW PRIORITY — Lock Files (Acknowledge Only)

**Do NOT review contents.** Simply note their presence.

| File | Package Manager |
|------|----------------|
| `package-lock.json` | npm |
| `yarn.lock` | Yarn |
| `pnpm-lock.yaml` | pnpm |
| `uv.lock` | uv (Python) |
| `go.sum` | Go |
| `Cargo.lock` | Rust |

## SKIP — Documentation-Only Changes

Typically excluded from automated review (filtered by workflow paths).

| Pattern | Type |
|---------|------|
| `*.md` | Markdown |
| `*.txt` | Text |
| `*.rst` | reStructuredText |
| `docs/**` | Documentation directory |
| `LICENSE` | License file |
| `.gitignore` | Git ignore |
