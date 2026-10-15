---
file: log
---
# Work log

- 2026-10-15: diskcode 3.8 — 2-hunk AUTOINIT (second hunk
  empty). Raw .byte h0 + fixup; BYTE-IDENTICAL.
- Generic AUTOINIT oracle + invalid-access counter hook:
  21 vectors + lifecycle; 73.5M deterministic invalid reads
  counted identically. RUNTIME-IDENTICAL. Plane AMIGALIBS-332.
