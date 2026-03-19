# TDD Examples

## TypeScript + vitest

### Scenario: `formatCurrency(amount: number, currency: string): string`

**Step 2 — Signature:**
```ts
// src/format.ts
export function formatCurrency(amount: number, currency: string): string;
```

**Step 3 — Stub:**
```ts
export function formatCurrency(amount: number, currency: string): string {
  throw new Error("Not implemented");
}
```

**Step 4 — Tests (Red):**
```ts
// src/format.test.ts
import { describe, it, expect } from "vitest";
import { formatCurrency } from "./format";

describe("formatCurrency", () => {
  it("formats USD with dollar sign", () => {
    expect(formatCurrency(1234.5, "USD")).toBe("$1,234.50");
  });
  it("formats JPY without decimals", () => {
    expect(formatCurrency(1234, "JPY")).toBe("¥1,234");
  });
});
```

Run: `npx vitest run src/format.test.ts`
Expected: both tests fail with `Error: Not implemented`

**Step 5 — Green:**
```ts
export function formatCurrency(amount: number, currency: string): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency,
    maximumFractionDigits: currency === "JPY" ? 0 : 2,
  }).format(amount);
}
```

Run again → both tests pass.

---

## Python + pytest

### Scenario: `calculate_discount(price: float, rate: float) -> float`

**Step 2 — Signature:**
```python
# src/pricing.py
def calculate_discount(price: float, rate: float) -> float: ...
```

**Step 3 — Stub:**
```python
def calculate_discount(price: float, rate: float) -> float:
    raise NotImplementedError
```

**Step 4 — Tests (Red):**
```python
# tests/test_pricing.py
import pytest
from src.pricing import calculate_discount

def test_calculates_10_percent_discount():
    assert calculate_discount(100.0, 0.10) == 90.0

def test_zero_discount_returns_original_price():
    assert calculate_discount(50.0, 0.0) == 50.0
```

Run: `pytest tests/test_pricing.py -v`
Expected: both fail with `NotImplementedError`

**Step 5 — Green:**
```python
def calculate_discount(price: float, rate: float) -> float:
    return price * (1 - rate)
```

Run again → both tests pass.
