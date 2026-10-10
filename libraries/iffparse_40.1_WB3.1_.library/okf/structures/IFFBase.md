---
type: Structure
title: IFFBase (library base)
description: Private library base layout, 0x44 bytes.
resource: source/iffbase.h
timestamp: 2026-10-10T18:00:00Z
---

# IFFBase

InitTable `dataSize` is 0x44.  The base is `struct Library` (34 B)
plus private fields.  Field offsets were recovered from LibInit /
expunge stores in the binary:

| offset | field | evidence |
|-------:|-------|----------|
| 0x00 | `struct Library ib_Lib` | revision set at +0x16 |
| 0x22 | `UWORD` pad | gap before SysBase (never accessed) |
| 0x24 | `APTR ib_SysBase` | `movel a6,a5@(36)`; used as `moveal a6@(36),a6` everywhere |
| 0x28 | `APTR ib_DOSBase` | `movel d0,a5@(40)`; CloseLibrary'd on expunge |
| 0x2c | `APTR ib_UtilityBase` | `movel d0,a5@(44)`; CloseLibrary'd on expunge |
| 0x30 | `BPTR ib_SegList` | `movel a0,a5@(48)`; returned by expunge |
| 0x34 | `APTR ib_SMult32` | `lea a5@(52),a0` fill loop start |
| 0x38 | `APTR ib_UMult32` | |
| 0x3c | `APTR ib_SDivMod32` | |
| 0x40 | `APTR ib_UDivMod32` | ends at 0x44 |

## Cached utility vectors

LibInit does `lea a1@(-138),a1` on the utility base then stores four
consecutive jump-table slot *addresses* (stride -6): util-138
(SMult32), util-144 (UMult32), util-150 (SDivMod32), util-156
(UDivMod32).  The code calls them via `jsr a5@(52)`-style indirect
jsr through the stored slot address (trampolines at text 0x194c-
0x1963), i.e. it jumps into the callee library's vector table entry.
This lets the compiler's 32-bit math helpers run without reloading
a6.
