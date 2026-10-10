---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-10
- Parsed two-hunk module: CODE 0x5a4, DATA 0x98.  Data hunk =
  functab (6 abs vectors + -1L), name, idstring, InitTable
  (dataSize 0x38, no InitStruct), RomTag, EndSkip.
- Idstring reveals this is a clean-room "Emulation by Stephan
  Rupprecht" of the 45.1 original — not Commodore code.
- Decoded vectors: open/close/expunge (DELEXP dance), reserved
  stub shared by -24/-30 (`clr.l d0` this time), WBStart @ -36.
- WBStart: NextTagItem loop over TAG_USER+1..7; builds WBOPENA_
  ArgLock/ArgName taglist via AllocVec; object start is
  reimplemented: "VOL:" opens directly, "dev:dir/file" probes
  Lock(name)/Lock("name.info") then ParentDir+CurrentDir+
  FilePart, bare names fall back to the Workbench search path
  (WBCTRLA_DuplicateSearchPath) and PrintFault on failure.
- Quirks recorded: RomTag RT_VERSION 2 + runtime self-patch of
  that byte, CloseLibrary(NULL) crash path on init failure,
  68000-illegal `tst.l a0` (0x4a88) in the tag loop, dead
  strcat/strcpy code at end of the code hunk.
- Reconstructed C + asm header; `make` builds a valid
  `wbstart.library`.
