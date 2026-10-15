---
type: Finding
title: bitmap.library 1.4 quirks
---

# Quirks / defects

- **Hidden-instruction trick**: the functab/initfn block uses
  hand-placed words so the InitTable's 0x60-copy loop and the
  initfn share bytes; e.g. `cmpi.w #$1cd9,d0`, `cmpi.w #$200d,d0`,
  `cmpi.w #$7001,d0` opcodes are actually crafted D0 constants so
  that executing through a shifted entry yields `moveq #`, `move.l`
  sequences.  Emitted raw (.short) in the reconstruction — gas
  canonicalisation of these regions would break bytes.
- **Vestigial self-relocator**: initfn copies 40B of hunk1 into
  lib+0x30 and then runs a loop that would fix up relocated
  pointers inside the copy — but the fixup count (hunk1+40) is 0,
  so the copied functab/initfn pointers are stale for life.
  Only the "graphics.library" string portion is actually consumed.
- **GfxBase version gate at runtime**: every call to -30/-36 reads
  `gfxbase->lib_Version` via the ptr stored at lib+0x5c, not a
  cached flag — patching the fake GfxBase word flips alloc/free
  between manual-plane and AllocBitMap/FreeBitMap code paths.
- **-54 FreeMem asymmetry**: frees `4 * w@2(A2)` bytes at A1 —
  the companion to -48's count*4 alloc.  Passing a mismatched
  desc corrupts the heap (caller-beware, same pattern as exec
  FreeMem misuse elsewhere).
- **Null bm in -30**: `FreeBM(NULL)` falls through safely (0 -> rts).
- **OpenLibrary version arg**: initfn calls OpenLibrary(name, 0);
  a missing graphics.library leaves D0=0 and initfn returns 0 —
  the library fails to init entirely rather than partially.
