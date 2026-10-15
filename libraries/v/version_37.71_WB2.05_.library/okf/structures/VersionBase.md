---
type: Structure
title: VersionBase
description: Private library base, 0x2c bytes (struct Library + SysBase + SegList + flags).
timestamp: 2026-10-10T19:00:00Z
---

# VersionBase — library base layout

`InitTable.dataSize` is 0x2c (44).  The first 34 bytes are the public
`struct Library`; MakeLibrary/InitStruct fill in `ln_Type` (9),
`ln_Name`, `lib_Flags` (6 = LIBF_SUMUSED|LIBF_CHANGED),
`lib_Version`=37, `lib_Revision`=71 and
`lib_IdString`.  `lib_NegSize`/`lib_PosSize` are written by
MakeLibrary itself.

| offset | field | notes |
|--------|-------|-------|
| 0x00   | `struct Library vb_Lib` | standard, 34 bytes |
| 0x22   | `vb_SysBase` | ExecBase, stored by the init vector (a6) |
| 0x26   | `vb_SegList` | seglist, stored by the init vector (a0) |
| 0x2a   | `vb_Flags`   | private flags; bit 3 = deferred expunge |
| 0x2b   | pad          | |
