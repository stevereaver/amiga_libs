---
type: Structure
title: VersionBase (library base)
description: Private library base layout, 0x2a bytes.
resource: source/versionbase.h
---

# VersionBase

InitTable `dataSize` is 0x2a: `struct Library` (34 bytes) plus two
private longs.  Field offsets recovered from the init routine and
the expunge path in LibClose:

| offset | field | evidence |
|-------:|-------|----------|
| 0x00 | `struct Library vb_Lib` | lib_Revision store at +0x16, OpenCnt at +0x20 |
| 0x22 | `struct ExecBase *vb_SysBase` | `movel a6,a5@(34)` in init; `moveal a5@(34),a6` before FreeMem |
| 0x26 | `BPTR vb_SegList` | `movel a0,a5@(38)` in init; returned in d0 by the free path |

LibInit entry convention (AUTOINIT): `d0` = base, `a0` = seglist,
`a6` = SysBase.  The routine does `exg d0,a5`, stores the fields,
writes `lib_Revision = 42` (`movew #$002a,22(a5)`), swaps back and
returns the base in d0.  **Quirk:** the ID string says "40.43" but
the stamped revision is 42 — see
[RevisionMismatch](../findings/RevisionMismatch.md).
