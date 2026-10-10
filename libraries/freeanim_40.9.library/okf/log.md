---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2026-10-10

- Parsed hunk: single code hunk 0x130 bytes, 0x10 relocs.
- RomTag AUTOINIT|COLDSTART v40; EndSkip = hunk end.
- Function table: 4 entries → Open 0xf0 / Close 0xf8 / Expunge 0x94 /
  null stub 0x90.  No public API.
- Decoded guarded Close (double zero-check + DELEXP), seglist-based
  Expunge via absolute ExecBase, init storing seglist@+0x22.
- Reconstruction: header .s + C lifecycle + two-pass word-offset
  functab; InitStruct in `datatab.s`.  `make` builds a valid HUNK
  library; vector order and strings verified.
