---
file: defects
---
# Findings

- initfn/libInit returns 0 under stub emulation (dep open
  fails) — vectors still installed, exercised cleanly.
- One vector walks unmapped memory: 73,587,352 deterministic
  invalid byte reads before completing — likely a disk
  region scan without a bounds cap. Preserved, identical
  count on rebuild.
- Trailing empty h1 (0-len linker artifact).
