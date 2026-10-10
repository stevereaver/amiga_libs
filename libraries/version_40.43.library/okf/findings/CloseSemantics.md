---
type: Finding
title: Non-standard Close/Expunge semantics
description: Expunge is a no-op stub; LibClose unlinks and frees the library unconditionally when OpenCnt reaches 0.
---

# Non-standard Close/Expunge semantics

version.library deviates from the usual Commodore library contract:

- **Expunge (LVO -18) is a stub.**  Its function-table entry points
  at the shared `moveq #0,d0 / rts` (text+0xba), identical to
  ExtFunc (-24).  Calling Expunge() returns NULL and does nothing.
- **LibClose frees the library unconditionally** when
  `lib_OpenCnt` reaches 0: it unlinks the node from
  `SysBase->LibList` (inline, not via `Remove()`) and calls
  `FreeMem(base - NegSize, NegSize + PosSize)`, returning the
  seglist.  There is **no `LIBF_DELEXP` test** and no DELEXP flag
  is ever set or cleared anywhere (LibOpen does not clear it
  either).

Consequence: this library can never stay resident after its last
Close.  That is safe in practice because version.library has no
public functions — callers OpenLibrary() it only to read
lib_Version/lib_Revision/lib_IdString.

Reconstruction note: the C `LibClose` returns NULL on the
still-open path whereas the original falls through `rts` with a
stale d0.  The documented Close contract only requires the seglist
on the expunge path, so this is a cosmetic deviation.
