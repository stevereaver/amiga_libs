---
type: Finding
title: Code 0x80 emits exactly one byte
description: neg.b of -128 sets V; ble falls through, one emit, bgt exits.
timestamp: 2026-10-15T00:00:00Z
---

# Code 0x80 emits exactly one byte

(Corrects the 2026-10-10 finding, which claimed "decodes to
nothing".)

The decoder treats `code<0` as "repeat the next byte `-code` times".
For code 0x80 the flag gymnastics do *not* produce a clean skip:

1. `neg.b` of -128 yields -128 again with **V=1** (the only value for
   which NEG overflows), so `ble` — testing Z | N≠V — is NOT taken
   (N==V==1).  The emit loop is entered.
2. The repeat byte is emitted once; `subq.b #1` then wraps -129 into
   +127, again setting **V=1**, and `bgt` (N=0, V=1 → N≠V) fails.

Net effect: a 0x80 control byte consumes the following stream byte
and emits it **once**.  Same observable result as a 0x81 code (run
of one), so it's a legal-but-useless encoding — the encoder never
generates it.  Verified under machine68k in `work/oracle.py`
(`03 'abc' fd 'Z' 80 'Q' 02 'XY' 00` decodes to `abcZZZQXY`).

Note the 1.5(000) decoder dispatches on `bmi`/`beq`/`bne` instead —
there the same token emits the byte **128** times.
