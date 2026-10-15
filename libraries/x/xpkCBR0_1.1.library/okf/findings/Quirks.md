---
type: Finding
title: Quirks
description: Oddities of the shipped binary.
---

# Quirks

1. **Module entry returns -1** (`moveq #-1,d0/rts`) —
   like other XPK sublibs; the resident scan treats a
   nonzero return as failure.

2. **Runtime-initialised descriptors.**  LibInit writes
   0x58+0x2a bytes of descriptor data into the base
   instead of linking static structures — presumably so
   the same source builds several packer variants.

3. **Two null stubs**: ExtFunc (-24) gets
   `moveq #0,d0/rts` (returns 0) while the three unused
   sublib slots (-42/-48/-60) share a bare `rts` —
   returning whatever d0 held, an impure stub.

4. **Output bound `dst + 256 + params[3]`** in both
   codecs — the +256 allowance suggests the params[3]
   field is already reduced by the xpk master for its
   own header space.

5. **Expansion guard -17**: chunks that would grow
   (output reaching dst+insize) are rejected rather than
   stored — e.g. a 1-byte input always fails to pack.
   The xpk master falls back to uncompressed storage.

6. **xm_ChunkSize = 63** and DefMode = 50 (mode "normal")
   — unusual values, preserved verbatim.
