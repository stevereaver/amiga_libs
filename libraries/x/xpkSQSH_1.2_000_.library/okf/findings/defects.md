---
type: Finding
title: defects and inconsistencies
---

# xpkSQSH 1.2 (000) — defects & inconsistencies

All codec-level defects of the 020 twin apply verbatim (same
algorithm): output budget = inlen (-17 rejection on small or
incompressible inputs); match lookahead reads up to 46 B past
in+inlen so tail "matches" can be fabricated from trailing memory;
literal runs overshoot the last token; the decoder trusts the stream
entirely; descriptor PackMem (0x2080) disagrees with the real alloc
(0x22080); `xsp_Sub[0]` stays stale after free; reserved vectors land
on the entry stub. See
[`../../xpkSQSH_1.2_020_.library/okf/findings/defects.md`](../../xpkSQSH_1.2_020_.library/okf/findings/defects.md).

000-specific notes:

1. **No CPU gate**: LibInit lacks the 020 build's `btst #1,AttnFlags`
   check — correct, since the whole hunk is bitfield-free.
2. **Litpress gate semantics**: the two `cmpaw #7` gates are strict
   `> 7` comparisons (`bhis`/`blss` on opcode 0x62/0x63 — note that
   some disassemblers render opcode 0x62 as `bhis`, which reads as
   "higher or same" but is actually **BHI, strictly greater**). The
   narrowing therefore engages at litpress >= 8, consistent with the
   decoder. An earlier reconstruction note claiming an off-by-one
   defect here was wrong.
3. **`__mulsi3` in the original**: the 68000 build carries compiler
   runtime helpers — `p->bitpos += w` inside the run loop is strength-
   reduced to `w*run` even at the source's semantics, and 68000 has
   no 32x32 multiply. The reconstruction supplies the same stub in
   `xpkSQSH_lib.s`.
4. **-60 vector is the entry stub, not PackFree**: unlike the 020
   (where -60 == -42), unused vectors -24/-48/-60 all point at
   `moveq #0,d0;rts`.
5. **Oracle-verified**: machine68k runs of the reconstruction produce
   streams byte-identical to the original on all 16 corpus inputs
   (and those match the 020 original's streams). Round-trips through
   the library's own unpacker are exact.
