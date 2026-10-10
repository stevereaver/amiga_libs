---
type: Structure
title: InitTable / RomTag
description: Resident module header layout in the DATA hunk.
timestamp: 2026-10-10T21:10:00Z
---

# InitTable / RomTag

Two-hunk module; the DATA hunk carries, in order:

| offset | contents |
|---|---|
| 0x00 | function table: 6 absolute longwords + -1L |
| ...  | `wbstart.library\0`, idstring (see index.md) |
| ...  | InitTable: dataSize 0x38, funcTable, no InitStruct, initFunc |
| ...  | RomTag: 0x4AFC, RTF_AUTOINIT, RT_VERSION **2**, NT_LIBRARY, pri 0 |
| end  | EndSkip word covering the data hunk |

No InitStruct data table exists: exec `InitResident` copies
rt_Name/rt_IdString/rt_Version into the base, and the init
routine writes `lib_Revision = 2` itself — and **also writes 2
through the RomTag's RT_VERSION byte**, a self-modifying patch
of the data hunk (`rtversion[]` symbol in the reconstruction).

The module loader entry returns -1 (`moveq #-1,d0/rts`) — the
file is not a runnable program.
