---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
timestamp: 2026-10-10T19:00:00Z
---

# Log

## 2026-10-15
- `source/version.s` + `fixup.py` byte-exact rebuild incl. the
  empty second CODE hunk record and original reloc ordering.
- machine68k oracle identical: InitStruct fills hdr (type 9, ver 38,
  rev 36); Open/Close/Expunge via private DELEXP bit at lib+42; -24 stub.

## 2026-10-10
- Phase 1: recorded binary facts (size 384, sha256 6f82bbb9685f284bab05b7fce2703a55f2c3ec0c73c05aa090d7724cfa65d932,
  $VER "version 38.36 (4.12.92)", hunk map).  Disassembled with IRA 2.09 into
  work/; cross-checked header with objdump -h.
- Parsed RomTag (RTF_AUTOINIT, version 38, NT_LIBRARY), the
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
