---
file: log
---
# Work log

- 2026-10-15: catharsis 2.11 (27-Apr-03) — 3-hunk (CODE+DATA
  +BSS) SAS/C-style lib. Raw .byte + hgrexxsupport resplit
  fixup verbatim; BYTE-IDENTICAL first try. Oracle: RomTag
  @h0+0xe70 AUTOINIT -> InitTable@h1+0xb8, initfn opens
  graphics+intuition v33 into BSS+4/+8, 23 abs-long vectors
  (incl. relocated-0 -30 ->CODE+0), sem-guarded 256-slot table,
  deferred expunge; RUNTIME-IDENTICAL, 0 invalids.
