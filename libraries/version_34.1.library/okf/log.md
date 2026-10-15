---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
timestamp: 2026-10-10T19:00:00Z
---

# Log

## 2026-10-10
- Phase 1: recorded binary facts (size 404, sha256 6515322765306b36ceb9fcf9d9e2d5b328e79b0711ceae0d8a9d291a1ba518b1,
  $VER "versionlib 34.1 (06 JUL 1988)", hunk map).  Disassembled with IRA 2.09 into
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
- Result: **byte-identical** (md5 `3bf2bb3ca4aa12ccdd47e3d2d328f61e`).
- `work/oracle.py` (machine68k): init, Open, Close, Expunge, null vec,
  reopen, deferred+real expunge — **RUNTIME-IDENTICAL**
  (orig.log == rebuild.log).
- `version.c`/`version_lib.s`/`endmodule.s` kept as C semantic
  reference (`make cmodel`).
