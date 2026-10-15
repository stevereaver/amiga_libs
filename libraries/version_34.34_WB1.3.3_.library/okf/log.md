---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
timestamp: 2026-10-10T19:00:00Z
---

# Log

## 2026-10-10
- Phase 1: recorded binary facts (size 392, sha256 844df9bb92c2c585f012f20d774c907a08c025296eebc3d828b77b86355dbbb7,
  $VER "versionlib 34.34 (05 OCT 1990)", hunk map).  Disassembled with IRA 2.09 into
  work/; cross-checked header with objdump -h.
- Parsed RomTag (RTF_AUTOINIT, version 34, NT_LIBRARY), the
  AUTOINIT InitTable (dataSize 0x2c), the 4-entry absolute-long
  function table (Open/-6, Close/-12, Expunge/-18, Null/-24) and the
  InitStruct data.  No version_lib.fd exists in the NDK; all four
  vectors are the standard skeleton so names are unambiguous.
- Phase 2: wrote source/ (version_lib.s header+tables, version.c,
  endmodule.s, Makefile).  Absolute-long vector table
  means no genfunctab second pass is needed; the Makefile documents
  this.
- Verified: `make` produces a valid .library; RomTag fields, name/id
  strings, InitTable layout, InitStruct bytes and entry instruction
  are byte-identical to the original; vector order and semantics
  match the disassembly.
- Phase 3: populated this okf bundle.
- Status: FULL.

## 2026-10-15 — byte-identical asm rebuild
- Replaced the earlier functional C reconstruction with verbatim 68k
  assembly (`source/version.s`): RomTag/strings/InitTable/functab/
  datatab (raw-decoded InitStruct cmds incl. off16 c000/d000/e000
  forms where present) + all 4 vectors.
- `source/fixup.py` rebuilds the tail: declares the second empty CODE
  hunk and rewrites RELOC32 in the original descending order.
- Result: **byte-identical** (md5 `6fa3a150e3c71ecac06c46400b1d6ba3`).
- `work/oracle.py` (machine68k): init, Open, Close, Expunge, null vec,
  reopen, deferred+real expunge — **RUNTIME-IDENTICAL**
  (orig.log == rebuild.log).
- `version.c`/`version_lib.s`/`endmodule.s` kept as C semantic
  reference (`make cmodel`).
