---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
timestamp: 2026-10-10T19:00:00Z
---

# Log

## 2026-10-10
- Phase 1: recorded binary facts (size 384, sha256 7aa6e88a38e95d7096934d8a3520b72b4a65075aadb60f2a50aadc346627dea3,
  $VER "version 37.71 (9.1.92)", hunk map).  Disassembled with IRA 2.09 into
  work/; cross-checked header with objdump -h.
- Parsed RomTag (RTF_AUTOINIT, version 37, NT_LIBRARY), the
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
  assembly (`source/version.s`, same template as version_37.67):
  RomTag/strings/InitTable/functab/datatab + all 4 vectors.
- `source/fixup.py` rebuilds the file tail: declares the second
  (empty) CODE hunk in the header and appends its record; rewrites
  the 14 RELOC32 slots in the original's descending order.
- Result: **byte-identical** to `binary/version_37.71(WB2.05).library`
  (md5 `cd11aaabbbfd0cb23eae59edf16d321b`, 384 B).
- `work/oracle.py` (machine68k): init, Open, Close, Expunge, null
  vector, reopen, deferred-expunge + last-close real expunge —
  original vs rebuild **RUNTIME-IDENTICAL**
  (`work/orig.log` == `work/rebuild.log`).
- `version.c`/`version_lib.s`/`endmodule.s` kept as the semantic C
  reference (`make cmodel`); not byte-identical.
