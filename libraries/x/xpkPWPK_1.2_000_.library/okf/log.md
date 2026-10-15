---
type: Log
title: Work Log
description: Chronological journal of analysis sessions.
---

# Log

## 2026-10-15
- Hunk parse: single CODE hunk 0x2fe longs (3064B) + 17-entry
  RELOC32.  IRA -M68000 -PREPROC -AW disasm -> work/pwpk_a.asm.
- work/gen.py translates IRA lines to gas: real mnemonics where
  canonical, raw .byte/.short/.long for data/functab/jump tables.
  gas canonicalization fixes needed: `0(An)` collapsed to `(An)`
  (forced .short), `MOVEA.L <abs>` w/o .W -> absl (`:l`), pc-indexed
  JMP forced .short.
- source/xpkPWPK_h0.s -> link -> fixup.py splices original RELOC32
  tail -> BYTE-IDENTICAL (md5 41affc8a958ef52dcf35dc4ceb6ae9eb).
- work/oracle.py: machine68k, exec Remove/FreeMem/AllocMem stubs
  (bump heap); covered init, all 10 vectors, pack/unpack
  round-trips plain+userdata-crypt, corrupt trailer -32, ctx free,
  deferred+real expunge.  orig.log == rebuild.log ->
  RUNTIME-IDENTICAL.
- Note: machine68k `execute()` has a default 1000-cycle budget —
  the oracle loops `m.execute(10_000_000)` until the endtrap.
