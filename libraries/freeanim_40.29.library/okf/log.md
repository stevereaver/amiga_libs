---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2026-10-10

- Parsed hunk header: 1 code hunk (0x6c bytes), 7 REL32 relocs.
- RomTag: AUTOINIT, v40, NT_LIBRARY, pri 0; EndSkip→0x6a (mid-module
  pad word).
- InitTable: dataSize 0x2a, no InitStruct, initFunc = the shared stub.
- Function table: 4 word-offset entries, all → code+0x66
  (`moveq #0,rts`).  LVOs -6/-12/-18/-24 resolved to the same routine;
  no public API.
- Reconstruction: `source/freeanim_lib.s` (RomTag/strings/InitTable),
  `source/freeanim.c` (LibNull), two-pass `genfunctab.py` word-offset
  table, `endmodule.s`.  `make` → valid HUNK library; RomTag fields,
  vector order, strings verified vs original.
- Findings: init returning 0 makes the library unloadable;
  id string lacks `$VER:`.
