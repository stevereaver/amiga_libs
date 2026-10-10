---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-10
- Parsed module: CODE 0x410, RomTag ver 1, InitTable 0x44 +
  InitStruct, 7 abs vectors.
- -30: cached language detect: lowlevel GetLanguageSelection
  (6→0, 3→2, else 1), else locale name prefix "ital"/"deut",
  else RAW: console prompt + raw-byte F-key read.
- -42/-36: borrow/restore GfxBase->ActiView + colour 0
  (LoadView, WaitTOF x2, SetRGB4/GetRGB4).
- Reconstructed in C with NDK inline lib calls; verified codegen
  loads the right base into a6 per call.
