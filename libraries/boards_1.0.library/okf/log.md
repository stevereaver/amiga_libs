---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2026-10-10

- Parsed hunk: single code hunk 0x200 bytes, 0x11 relocs.
- RomTag AUTOINIT v1; EndSkip = hunk end.  Copyright string decoded
  (Körber, "Replaces boards.library by Torsten Bach").
- Function table is absolute-long: Open/Close/Expunge/reserved/
  BoardsFunc + -1.
- Init: stores libbase (dead cell), SysBase, seglist; opens
  expname.library v1; NULL on failure.
- -30 vector: relay to expname -30 + not.l d0 (name inferred).
- Reconstruction: header .s, functab.s (.long), datatab.s,
  boards.c lifecycle, boards_func.s (cells + relay), endmodule.s.
  `make` → valid HUNK library.
