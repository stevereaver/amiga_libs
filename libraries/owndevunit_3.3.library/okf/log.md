---
file: log
---
# Work log

- 2026-10-15: owndevunit 3.3 — 3-hunk AUTOINIT with a
  declared-vs-physical CODE hunk size anomaly. Raw .byte
  verbatim (h0+h2 .text, h1 .data); fixup verifies merged
  bodies and writes the original structure. BYTE-IDENTICAL.
- Generic AUTOINIT oracle patched to absorb the extra body
  long; 11 vectors + lifecycle RUNTIME-IDENTICAL.
  Plane AMIGALIBS-330.
