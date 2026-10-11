# algorithms

## LZ-Speeder encoder (LAB_0019..LAB_0035)

Workmem (one lazy AllocMem of 0x80004 bytes per xsp_Sub[0]):

    buf[0]            allocation-size long (0x80004)
    sub+0x00000       ULONG head[65536]    newest position per key
    sub+0x40000       ULONG chain[65536]   prev position, slot pos&0xffff

Entries are raw pointers.  The original addresses head[] with a
NEGATIVE index off a base at sub+0x40000 (`d1 = 0xffff0000|key`,
`d1.l*4` wraps to sub+0 + key*4); the C models both halves as one
flat ULONG table.

Key: `move.w (a2),d1; add.b 2(a2),d1` -> `b0<<8 | ((b1+b2)&0xff)`.
The add is BYTE-wide: no carry into the b0 half.

Search (LAB_002C): guard `remaining >= 3` (unsigned -- underflowed
remaining passes).  maxlen = min(258, remaining).  Walk chain
newest-first; exit when `cur - cand >= 0x10000` SIGNED (bge) --
also the empty-head (cand=0) exit.  Quick-check `cur[best]` vs
`cand[best]`; full verify+extend; strictly longer wins, so the
nearest candidate keeps ties.  The whole best is carried packed
`(dist<<16)|len`; initial packed value is 2 (dist 0, len 2).

Lazy pass (LAB_001C..LAB_0021): budget d3 = (xsp_Mode-1)/25
(subq.b+divu; mode 0 -> 0 = greedy).  Probes advance one position
each; adopt when `nlen - adv > best` (signed .w).  On adopt the
walker rewinds `adv` positions and literalises them one at a time
(emit byte, insert, remaining--, flag shift, outend check), then
resumes with adv=1.  Exhausted probes rewind `cur -= adv-1`.
A best of 258 short-circuits further lazy work.

Emit: `len >= 3` -> `[-dist:u16][len-3:u8]`, flag bit 1 via
`ori #$10,ccr; addx.l`; else literal, flag bit 0.  Flag long
flushed when the low-seeded sentinel shifts out of bit31.

Insert (LAB_0029/002B): checks `remaining >= 3` ONCE, then chains
all `len` consumed positions -- a match touching the last two
input bytes reads up to 2 bytes past the buffer end.

Terminator: one match-flagged sentinel shift, zero-fill until the
sentinel exits, write the flag long, write a zero word (the write
is NOT bounds-checked).

## Decoder (LIBFUNC_5)

`d0 = 31` item counter per flag long; `add.l d2,d2` consumes MSB.
Flag long 0 -> 8 `move.l` copies = 32 literals.  Match bit -> token
word into `d1 = 0xffffWWWW` (seeded `moveq #-1`), so
`lea (0,a1,d1.l),a2` = `dst + tok - 0x10000` = backward copy for
EVERY token 1..0xffff (a C SHORT is wrong above 32 KB).  len byte
+3 via an unrolled copy; len byte 0 still copies 3.  Zero token
word ends; no output-length writeback, no bounds checks.
