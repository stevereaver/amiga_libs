---
type: Finding
title: Rebuild delta
description: Byte-identical asm rebuild vs the shipped binary.
timestamp: 2026-10-15T00:00:00Z
---

# Rebuild delta

`source/xpkFRLE_h0.s` is a verbatim GNU-as transcription of the
CODE hunk; `make` produces a BYTE-IDENTICAL binary (md5
`45381000923f1a67ca73aad8526201ff`, cmp clean).  The shipped
hunk's RELOC32 offset table is stored in DESCENDING order (the
original toolchain walked its reloc list back-to-front); GNU ld
emits the same 18 sites ascending, so `source/fixup.py` rewrites
the tail entries in place after linking.

`work/oracle.py` (machine68k) drives every vector including real
pack/unpack round-trips, the deferred and real expunge paths, and
the OutBufLen overflow (-17); orig.log == rebuild.log.

Encoding notes discovered during transcription:

- The decoder's `and.b #0x3e,d1` and `sub.b #0x20/0x1f,d1` are
  encoded with the noncanonical AND/SUB-with-immediate-ea forms
  (`c23c`/`923c`), not ANDI/SUBI — emitted as raw `.short`s.
- The mid-repeat "done" branch is a word `bra` (`6000 0098`)
  where the sibling codecs use short branches.
- `eor.b d2,d5` in the tail-literal emit XORs the key register
  itself (d5 = 0x1f) instead of the count — harmless, d5 is
  never used again.
- Repeat/literal count decoders differ by one constant
  (+0x20 vs +0x1f bias), i.e. repeat tokens store `n-2`,
  literals `len-1`.
- OutLen store tricks differ: pack `suba.l -8(a0),a3` /
  `move.l a3,(a0)` (a0 left at pb+0x10), unpack
  `suba.l -(a0),a3` / `move.l a3,8(a0)` (a0 at pb+0x0c,
  predecremented to pb+0x08).

The earlier GCC C model (`make cmodel`) is superseded — it
rebuilt the layout but bounds input reads and caps literals at
exactly 128, so its emitted stream can differ from the original
on the defect inputs in EncoderDefects.md.
