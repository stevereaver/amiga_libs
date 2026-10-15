---
type: Structure
title: InitTable
description: Data-hunk function table, InitTable and RomTag layout.
timestamp: 2026-10-10T20:00:00Z
---

# Data-hunk layout (offsets into hunk, 0x78 bytes)

- 0x00 functab: 6 absolute vectors (Open, Close, Expunge,
  reserved@code+6, reserved@code+6, WBStart) + `-1L`
- 0x1c `wbstart.library\0`
- 0x2c `wbstart.library 45.1 (16.12.00)\0`
- 0x4c InitTable: `{0x38, functab, 0, INITFUNCTION@code+0x0c}`
- 0x5c RomTag: MATCHTAG self, ENDSKIP = +0x76 (one pad word at
  0x76-0x77), flags 0x80, **version 2**, type 9, pri 0
