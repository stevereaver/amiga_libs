---
type: Structure
title: LowMemBase
description: Private library base allocated by MakeLibrary (dataSize 0x3c).
timestamp: 2026-10-10T19:00:00Z
---

# struct LowMemBase — 0x3c bytes

| off | field |
|-----|-------|
| 0x00 | `struct Library` (34 bytes) |
| 0x22 | `struct ExecBase *` SysBase (stored by init) |
| 0x26 | `BPTR` seglist |
| 0x2a | `struct MinList` client list (head/tail/tailpred) |
| 0x36 | pad |
| 0x38 | `UWORD` private open count |
| 0x3a | pad |

InitStruct initialises only the public part: `ln_Type`=9,
`ln_Name`="asdg-low-mem.library", `lib_Flags`=6
(LIBF_SUMUSED|LIBF_CHANGED), `lib_Version`/`lib_Revision`=0,
`lib_IdString`=idstr.  The init routine stores SysBase + seglist and
news the MinList.
