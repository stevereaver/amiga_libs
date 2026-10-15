---
file: log
---
# Work log

- 2026-10-15: muihelp 19.9 (12.02.97) — 3-hunk SAS/C-style
  lib (CODE + DATA + flagged zero DATA, no BSS). Parsed hunk
  records: RELOC32 on h0 only, 3 groups (14->h0, 8->h1,
  1->h2). Raw .byte source + index-based resplit fixup
  (catharsis-derived; type-keyed map would collide on the two
  DATA hunks). `make` BYTE-IDENTICAL first try. Oracle:
  non-AUTOINIT RomTag in CODE hunk -> called rt_Init routine
  directly (A0=seglist); stubbed exec MakeLibrary builds the
  6-slot jump table; dep libs each mapped to a named stub
  base. Ran open x2, both user vectors (incl. deep render
  path with fake object graph + packed text extent), DELEXP
  deferred expunge, close-to-zero auto-expunge, final
  expunge. RUNTIME-IDENTICAL vs rebuild, 0 invalids.
