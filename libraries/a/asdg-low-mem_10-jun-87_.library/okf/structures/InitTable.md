---
type: Structure
title: InitTable
description: RomTag, InitStruct data and absolute function table layout.
timestamp: 2026-10-10T19:00:00Z
---

# InitTable / module header

- Module entry `clr.l d0 / rts` (returns 0, not -1).
- RomTag @0x04: matchtag->itself, EndSkip = end of code hunk
  (+748), flags 0x80 (AUTOINIT), version 0, type 9, pri 0.
- RT_IDSTRING points one byte past a 0 pad: the libname (21 bytes,
  odd) is padded to even before `"asdg low memory alert server
  (10-Jun-87)\r\n"`.
- Two further unreferenced strings in the code hunk:
  `Copyright 1987 By ASDG Incorporated\r\n`, `Perry S. Kivolowitz\r\n`.
- InitStruct data uses the 24-bit-offset command form
  (0xE0 byte / 0xD0 word / 0xC0 long).
- Function table: absolute longwords `Open, Close, Expunge,
  module-entry, RegLowMemReq, DeRegLowMemReq, LMSQuery, -1`.
- InitTable: `{dataSize=0x3c, funcTable, dataTable, initFunc}`.
