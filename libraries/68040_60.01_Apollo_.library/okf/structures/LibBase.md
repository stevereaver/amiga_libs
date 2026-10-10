---
type: Structure
title: LibBase
description: Bare struct Library — dataSize 0x22, no private fields.
---

# LibBase

The AUTOINIT dataSize is 0x22 = 34 = `sizeof(struct Library)`.
There are no private fields at all:

| offset | field        | source |
|--------|--------------|--------|
| 0x00   | struct Library | InitStruct data table |
| 0x08   | ln_Type = 9  | a008 0900 |
| 0x0a   | ln_Name      | initlong |
| 0x0e   | lib_Flags=6  | CHANGED\|SUMUSED |
| 0x14   | lib_Version=60 | 9014 003c |
| 0x16   | lib_Revision=0 | 9016 0000 |
| 0x18   | lib_IdString | initlong |
| 0x20   | lib_OpenCnt  | runtime |

Because nothing can be remembered (no SysBase, no seglist, no
forwarded-library pointer), LibOpen simply returns `a6` and the
pre-opened library found by LibInit is referenced only through
exec's resident library list.
