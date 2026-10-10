---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2026-10-10

- Parsed hunk: single code hunk 0x290 bytes, 0x18 relocs (incl.
  absolute jmp targets in JoyButtons).
- RomTag AUTOINIT v1; EndSkip = InitTable (mid-module quirk).
- Functab absolute-long: Open/Close/Expunge/reserved/JoyDir/
  JoyButtons.
- LibInit stores sysbase@0x22, dos@0x26, seglist@0x2a; dead bne.
- LibClose tests flag via caller's a5 (bug, reproduced);
  Expunge uses stored SysBase, movem mismatch (d1 push/d2 pop).
- Decoded JOY1DAT quadrature → d3 (0-8) and CIAA/POTGOR → d2
  ({0,1,2,4}); ported to fantasia_hw.s verbatim.
- Reconstruction builds a valid HUNK library.
