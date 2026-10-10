---
type: Library
title: patchtest 1.00
description: >-
  Minimal SAS/C test library: opens intuition.library per open
  and exposes a single vector that calls DisplayBeep(NULL).
timestamp: 2026-10-11T02:20:00Z
---

# patchtest 1.00

`patchtest.library V1.00 (c)1996 Hans B|hler (part of
dev/misc/Palis.lha)` -- a trivial test/demonstration library.
Each LibOpen does `OpenLibrary("intuition.library", 0)` (result
unchecked), each LibClose does `CloseLibrary()`, and the single
public vector (LVO -30) calls intuition `DisplayBeep(NULL)`
through the stored base.

## Binary facts

- sha256 a259e9daf35610785d857ce01bfbe844699e3d2bd22d18ad2248dac3129c83cc, 1216 bytes
- 3 hunks: hunk0 CODE 0x360 (all code + "intuition.library"),
  hunk1 DATA 0x20 (InitTable), hunk2 CODE 0x74 (functab +
  name/idstr) -- cross-hunk relocations throughout
- SAS/C build with per-open private data copies (jump table +
  base + data tail duplicated at each Open)
- entry `moveq #0,d0 / rts`; RomTag AUTOINIT ver 1 NT_LIBRARY
- InitTable dataSize 0x58; InitStruct dataTable NULL
- functab: Open/Close/Expunge/entry-stub/PTBeep, -1 terminator
- Exec LVOs: AllocMem -198, FreeMem -210, Remove -252,
  OpenLibrary -408, CloseLibrary -414, CacheClearU -636
- intuition LVO -96 (DisplayBeep)

## Public API (LVOs)

| LVO | name | behavior |
|-----|------|----------|
| -6  | LibOpen   | count++, clear DELEXP, OpenLibrary(intuition) |
| -12 | LibClose  | CloseLibrary, count--, DELEXP->expunge |
| -18 | LibExpunge| DELEXP or Remove+FreeMem, return seglist |
| -24 | (entry stub) | moveq#0/rts (functab -> hunk+0) |
| -30 | PTBeep    | DisplayBeep(NULL) via stored intuition base |

## Status

FULL - reconstructed C source builds a valid hunk library
(m68k-amigaos-gcc -m68000).  Reconstruction uses a conventional
single-base model rather than the SAS/C per-open copy; the
observable semantics (OpenLibrary per open, CloseLibrary per
close) are identical.  See findings/SASCRuntime.md.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
