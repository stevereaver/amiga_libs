---
type: Finding
title: Compact 0x3f7 reloc tail
description: The file ends with an old-style DREL record, not HUNK_RELOC32.
---

# Compact 0x3f7 reloc tail

After the single CODE hunk, the file does NOT carry a HUNK_RELOC32
(0x3ec).  It uses the older compact record form (type `0x000003f7`,
listed as HUNK_DREL32 in dos/doshunks.h) emitted by the Commodore
toolchain for AUTOINIT libraries:

    0000 03f7                      record type
    0008 0000                      count:word=8, target hunk:word=0
    0028 0024 0020 0018 0014 0010 0008 0004   16-bit offsets, descending
    0000 0000                      terminator
    0000 03f2                      HUNK_END

Each offset points at a longword inside the code hunk that is relocated
by adding the hunk base address (same semantics as RELOC32, only the
offset list is 16-bit).  The 8 relocated fields are the RomTag pointers
(rt_MatchTag, rt_EndSkip, rt_Name, rt_IdString, rt_Init) and the three
pointer slots of the InitTable (funcTable, dataTable, initRoutine --
initRoutine is stored as 0 and lands on the `rts` at hunk+0).

GNU ld cannot emit this record, so `source/fixup.py` rewrites the
RELOC32 tail it produces into this layout; the relocated offsets it sees
are asserted against the original list.
