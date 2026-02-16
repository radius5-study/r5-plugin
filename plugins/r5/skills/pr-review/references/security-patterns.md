# Security Check Patterns

Run these grep patterns on changed source files to detect potential security issues.

## Hardcoded Secrets

```
# API keys, passwords, tokens assigned as string literals
(api_key|apikey|secret_key|password|token|credential)\s*[=:]\s*["'][^"']{8,}

# Cloud provider credentials
(AWS|AZURE|GCP|GITHUB|SLACK)_[A-Z_]*\s*=\s*["'][^"']+
```

## Sensitive File Patterns

Check the changed files list for:
- `.env` files (should never be committed)
- `.pem`, `.key` files (private keys)
- `credentials`, `password`, `secret` in filenames

## Language-Specific Patterns

### TypeScript / JavaScript

| Pattern | Issue | Severity |
|---------|-------|----------|
| `// TODO`, `// FIXME` | Incomplete implementation | Medium |
| `: any` | Disables type checking | Medium |
| `eval(` | Code injection risk | Critical |
| `dangerouslySetInnerHTML` | XSS risk | High |
| `innerHTML` | XSS risk | High |
| `document.write` | XSS risk | High |
| `new Function(` | Code injection risk | Critical |

### Python

| Pattern | Issue | Severity |
|---------|-------|----------|
| `except:` (bare except) | Swallows all exceptions | Medium |
| `TODO`, `FIXME` | Incomplete implementation | Medium |
| `Any` (from typing) | Disables type checking | Medium |
| `exec(`, `eval(` | Code injection risk | Critical |
| `shell=True` | Command injection risk | High |
| `pickle.loads` | Deserialization risk | High |

### SQL / Database

| Pattern | Issue | Severity |
|---------|-------|----------|
| String concatenation in queries | SQL injection risk | Critical |
| `f"SELECT`, `f"INSERT`, `f"UPDATE`, `f"DELETE` | SQL injection risk | Critical |
| `.raw(` (ORM raw query) | SQL injection risk | High |

## Copainter-Specific Security Checks

### Server Actions

Verify every server action has:
1. Authentication check (`getServerSession`)
2. Input validation (zod schema)
3. Firebase Admin SDK usage (never client SDK)

### API Routes

Check for:
- JWT verification on protected endpoints
- Rate limiting where appropriate
- CORS configuration

### Stripe Webhooks

Verify:
- Webhook signature verification
- Idempotency handling
- Error recovery

### Environment Variables

Ensure no `.env` values are hardcoded. All secrets must use:
- `process.env.VARIABLE_NAME` in code
- GitHub Secrets in CI/CD
- Firebase environment config in functions
