---
type: Structure
title: InitTable
description: Module header tables and embedded strings.
timestamp: 2026-10-10T20:40:00Z
---

# Module layout (single CODE hunk, 0x410 bytes)

- 0x00 `moveq #-1,d0 / rts`
- 0x04 RomTag: RTF_AUTOINIT ver 1, name `lsdetect.library`,
  id `LightShock EnvDetector V1.0` via IDSTRING+1 (leading NUL)
- InitTable `{0x44, functab, datatab, initfunc}`; datatab =
  InitStruct byte stream (type, name, flags 6, ver 1, rev 0, id)
- functab: 7 absolute vectors + -1L
- strings in the code hunk: the four library names, the RAW:
  window spec, and the 94-byte F1/F2/F3 prompt
