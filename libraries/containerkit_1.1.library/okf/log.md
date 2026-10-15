---
file: log
---
# Work log

- 2026-10-15: containerkit 1.1 — resident-in-DATA GCC build.
  Raw .byte h0/h1 + resplit fixup; BYTE-IDENTICAL.
- Generic AUTOINIT oracle: InitTable@h1+0, 29 vectors +
  lifecycle, RUNTIME-IDENTICAL incl. deterministic invalid
  reads. Plane AMIGALIBS-329.
