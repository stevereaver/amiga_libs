---
file: log
---
# Work log

- 2026-10-15: Garshnelib 39.1 — 2-hunk SAS/C-ish build with
  a degenerate AUTOINIT resident (rt_Init -> RomTag) and a
  manual initfn that fills lib fields + installs a forward
  functab. Raw .byte for both hunks + fixup restoring the
  4B overrun and both RELOC32 tails; BYTE-IDENTICAL.
  Custom oracle (alloc lib, call initfn, walk functab):
  RUNTIME-IDENTICAL. Plane AMIGALIBS-338.
