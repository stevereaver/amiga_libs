---
file: defects
---
# Findings

- Nonstandard 26-byte resident: extra relocated pointer
  at +6 (->h0+0xbe, mid-functab) sits between EndSkip and
  the flags quad — a quirk of this lib's resident stub.
- EndSkip->h0+4 points AT the resident (self), not past it.
- h1 data ends with InitStruct `0001 0001 0000 039e` +
  "Include"/"MakeFlags" strings — ARexx host helpers.
- No invalid accesses under the harness.
