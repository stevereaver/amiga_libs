# xpkLZW4.library 4.3 (020) "LZ-Speeder"

Froehling XPK sublibrary: "LZ-Welsh (not Welch) 020+ V4.3" (id string
`xpkLZW4 V4.3 (1 Oct 2013) by Niels Froehling`).  Successor of xpkLZW3
3.3 in the same hash-chain family; the descriptor bills it "LZW3 like,
better compression".  1,536-byte single-hunk library; the packer needs
a 68020+ (LibInit gates on AFB_68020; it uses movm.l register lists).

## Vectors
| LVO | Function |
|-----|----------|
| -6/-12/-18 | LibOpen / LibClose / LibExpunge |
| -24/-60 | null `moveq #0,d0/rts` |
| -30 | `XpksPackerInfo` -> static XpkInfo descriptor |
| -36 | `XpksPackChunk` -- lazy LZ77 encoder (512 KB workmem) |
| -42 | `XpksPackFree` -- FreeMem(xsp_Sub[0]-4, buf[0]) |
| -48 | `XpksPackReset` -- clear the 256 KB head table |
| -54 | `XpksUnpackChunk` -- flag-long stream decoder |

## Layout
- `70ff 4e75` entry stub, packed RomTag: AUTOINIT, ver 1, NT_LIBRARY
- InitTable dataSize 0x22; LibInit stores the seglist at base+0x22
  (PosSize 34, legal because AllocMem rounds to 36) then fails the
  resident init on non-020 CPUs -- that is how the (020) tag is
  enforced.
- datatab: ln_Type 9, name, flags 6, ver 4, rev 3, idstring
- word-offset functab: -1 marker, 10 word offsets, -1

## Stream format
- one flag long per group of 32 items, consumed MSB first
- flag long 0x00000000: next 32 bytes are literals (decoder fast
  path: copies eight longs verbatim)
- bit 1 -> match token `[-dist:u16][len-3:u8]`; dist 1..0xffff
  (the token word is the negated distance: decoder forms
  `d1 = 0xffff0000|tok` so `dst + tok - 0x10000` reaches back
  0xffff..1 bytes; a SHORT sign-extend is NOT equivalent for
  distances > 32 KB)
- bit 0 -> literal byte
- len byte is len-3, so matches run 3..258; a zero len byte still
  means len 3 (decoder enters its unrolled copy at the tail)
- a zero token word terminates; the packer match-flags it so the
  decoder always takes the token path to read it

## Packer
- lazily AllocMem(0x80004) into xsp_Sub[0]: buf[0]=size, then
  head[65536] ULONG at sub+0 and chain[65536] ULONG at sub+0x40000
- PackReset clears exactly the 65536-long head table (the 3.3 fill
  underflowed 68 bytes into the size word -- fixed in 4.x); the
  chain ring is never initialised, harmless because the distance
  bound stops walks before stale entries can be followed
- hash key = `b0<<8 | ((b1+b2)&0xff)` -- `move.w`+`add.b`, so the
  third byte adds into the LOW BYTE only with no carry into b0
- head entries are absolute pointers; chain[pos&0xffff] is the
  previous pointer with the same key (64 KB position ring)
- match search walks the chain newest-first while `cur-cand <
  0x10000` (signed exit); quick-check `cur[best]==cand[best]` then
  full verify+extend; strictly longer wins so ties keep the
  nearest candidate; maxlen = min(258, remaining)
- lazy pass: budget = `(xsp_Mode-1)/25` extra probes per item
  (shipped modes give 0,1,2,3); a probe adopts when
  `nlen - adv > best` (signed 16-bit), rewinds, literalises the
  gap, and the adopted best is carried packed as (dist<<16)|len
- emit: len<3 literal (flag<<1); else `-dist` word + `len-3` byte
  (flag<<1|1); flag long flushed when the sentinel shifts out;
  output bound = outbuf + xsp_InLen, return -17 on overflow,
  -7 on AllocMem failure; xsp_OutBufLen ignored
- insert chains every consumed position once remaining>=3, so a
  match reaching the last two input bytes reads 2 bytes past the
  buffer (LAB_0029 quirk, kept)

## Decoder
- flag long MSB-first; 32 items per long; zero flag -> 32 literals
- token word 0 terminates; len byte+3; no outlen writeback
- no bounds checks anywhere (faithful to the original)

## Source
`source/xpkLZW4.c`, `xpkLZW4_lib.s`, `functab_stub.s`,
`genfunctab.py`, `endmodule.s`, `Makefile`.
Host differential: 5000 pack->unpack round-trips over random,
low-entropy, run-length, sparse and >64 KB periodic inputs at all
five mode budgets -- 0 failures (466 incompressible packs returned
-17 as designed).
