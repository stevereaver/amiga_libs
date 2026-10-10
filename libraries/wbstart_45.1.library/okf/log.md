---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-10
- Parsed two-hunk module: CODE 0x318, DATA 0x78.  Data hunk =
  functab (6 abs vectors + -1L), name, idstring, InitTable
  (dataSize 0x38, no InitStruct), RomTag (RT_VERSION 2!), EndSkip.
- Decoded vectors: open/close/expunge (DELEXP dance), reserved
  stub shared by -24/-30, WBStart @ -36.
- WBStart: NextTagItem loop over TAG_USER+1..7 (name, Lock,
  DupLock, 2 ignored, NumArgs, Args pairs); builds WBOPENA_
  ArgLock/ArgName taglist via AllocVec; PathPart+Lock+CurrentDir
  when no lock tag; OpenWorkbenchObjectA; returns 0 on success /
  20 otherwise.  dos LVO -876 confirmed as PathPart (fd bias 870).
- Reconstructed C + asm header; `make` builds; .data hunk is
  byte-layout identical to the original.
