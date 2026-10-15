---
type: Findings
title: dpblit.library (DPBlitBase) quirks
---

# Findings / quirks

- idstring has no '$VER:' marker — just 'DPBlitBase'; name and
  idstring differ (name 'dpblit.library', idstring 'DPBlitBase').
- One stray 'l' byte trails the idstring at hunk3+0x3b (linker
  junk inside the hunk body).
- Hand-packed branch-into-operand tricks in initfn:
  `cmpiw #0x1cd9,d0` @h0+0x7a has `move.b (a1)+,(a6)+` as its
  immediate field; the `bccs` @+0x80 re-enters mid-instruction to
  run it as a 28-byte copy loop.  Same trick at +0xb8:
  `cmpiw #0x200d,d0` embeds `move.l a5,d0` reached by `beqs` +0xb4.
  Reconstructed by emitting the cmpi as .byte halves with a label
  between (L7c/Lba).
- The copy loop clones hunk1 longs 0..6 into lib+0x30 — the
  InitTable block doubles as the private-data template, which is
  how lib+0x48 receives the $dff000 chip base.
- Dead code: a functab-relocate loop at h0+0x8c reads its count
  from hunk1+0x1c (=0) and never executes; literal `lea 0/1/7,a1`
  absolute loads used as constant materialization (compiler junk).
- RELOC32 groups in hunk0 are not monotonic (self group {0xa,0x6}
  descending; h3 group {0x5a,0x34,0x16,0x12}); hunk3's own group
  lists its 7 functab slots in descending order.
- hunk2 tag carries the MEMF_CHIP bit (0x400003ea) with an
  all-zero body — a chip-RAM scratch buffer, not BSS.
- Second Close underflows lib_OpenCnt to 0xffff after a real
  expunge already freed the lib (observed identically on both
  binaries — caller error, tolerated).
