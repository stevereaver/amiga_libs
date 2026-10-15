---
type: Finding
title: Non-AUTOINIT bootstrap, manual field init, spare base long
timestamp: 2026-10-10T20:10:00Z
---

# Init style

- `rt_Flags` = 0: no AUTOINIT. rt_Init is code that calls
  `MakeLibrary(functab, NULL, InitBase, 0x2a, seglist)` +
  `AddLibrary()` + returns 1 — the pre-AUTOINIT pattern, unusual for a
  2020 build but simple and portable.
- No InitStruct data exists; [InitBase](../functions/InitBase.md)
  writes every field manually.
- dataSize 0x2a leaves a 4-byte slot at base+0x26 that is allocated
  but never read or written — probably reserved for a SysBase pointer
  the author never needed (the code uses `4.w` throughout).
