---
type: Structure
title: VersionBase (library base)
description: Private library base layout, 0x36 bytes (extended since 44.x).
resource: source/versionbase.h
---

# VersionBase

InitTable `dataSize` is 0x36: `struct Library` (34 bytes) plus five
private longs.  Field offsets recovered from the init routine:

| offset | field | evidence |
|-------:|-------|----------|
| 0x00 | `struct Library vb_Lib` | lib_Revision store at +0x16, OpenCnt at +0x20 |
| 0x22 | `struct ExecBase *vb_SysBase` | `movel a6,a5@(34)`; reloaded before FreeMem |
| 0x26 | `BPTR vb_SegList` | `movel a0,a5@(38)`; returned by the free path |
| 0x2a | `struct Library *vb_Self` | `movel a5,a5@(42)` — self-pointer |
| 0x2e | `ULONG vb_Date` | `movel #$11081999,a5@(46)` — hardcoded 11.8.1999 in **all** 44.x/45.x builds |
| 0x32 | `APTR vb_Check` | `lea probe(pc),a0; movel a0,a5@(50)` — address of the hidden semaphore probe |

The three new fields (0x2a-0x35) are written once by LibInit and
never read inside the library — they exist for external consumers
that know the private layout.
