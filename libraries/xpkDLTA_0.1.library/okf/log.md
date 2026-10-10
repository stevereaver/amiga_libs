---
type: Log
title: Reconstruction log
---

# Log — xpkDLTA_0.1.library

- Scanned: 960-byte hunk; unusual layout — abs-longword
  functab, 0xfc base, InitStruct stream that fills the
  embedded descriptors.
- Phase 1: all 10 functab entries resolved to real
  vectors (no stubs beyond LibNull); reloc table checked
  to distinguish literal vs pointer InitStruct fields.
- Phase 2: codecs decoded — plain byte-delta
  (size-preserving), xsp_Sub[0]/[1] carry cross-chunk
  state; identified the n=0 dbf overrun in both kernels
  and the dead 16/32-bit kernels at the tail.
- Phase 3: C reconstruction; InitStruct stream emitted
  byte-identically (literal longs for scalars incl.
  'Byte'/'Mode', relocs for the six string fields).
  Host test: 20k random round-trips + 3-chunk
  continuation, all pass.  Fixed a pointer/index
  off-by-one introduced in the first draft.
- Phase 4: this OKF bundle; defects filed in Plane.
