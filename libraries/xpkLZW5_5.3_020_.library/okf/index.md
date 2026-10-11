# xpkLZW5.library 5.3 (020) "LZ-Speeder"

Froehling XPK sublibrary: "LZ-Welsh (not Welch) 020+ V5.3" (id string
`xpkLZW5 V5.3 (1 Oct 2013) by Niels Froehling`).  Successor of
xpkLZW4 4.3 in the same hash-chain family; the descriptor bills it
"Very Similar to TDCS".  1,592-byte single-hunk library; requires a
68020+ (LibInit gates on AFB_68020; the packer uses movm.l register
lists and divu).

## Vectors
| LVO | Function |
|-----|----------|
| -6/-12/-18 | LibOpen / LibClose / LibExpunge |
| -24/-60 | null (functab offset 0 -> -1 marker, never called) |
| -30 | `XpksPackerInfo` -> static XpkInfo descriptor |
| -36 | `XpksPackChunk` -- tiered lazy LZ77 encoder (512 KB workmem) |
| -42 | `XpksPackFree` -- FreeMem(xsp_Sub[0]-4, buf[0]) |
| -48 | `XpksPackReset` -- the defective downward fill |
| -54 | `XpksUnpackChunk` -- 2-bit flag-long decoder |

## Layout
- `7000 4e75` entry stub, RomTag: AUTOINIT, ver 1, NT_LIBRARY
- InitTable dataSize 0x26; LibInit stores the seglist at base+0x22
  then fails the resident init on non-020 CPUs.
- datatab: ln_Type 9, name, flags 6, ver 5, rev 3, idstring
- word-offset functab: -1 marker, 10 word offsets (0 for the two
  null vectors), -1

## Stream format (new vs 4.x: 2-bit item flags)
- one flag long per group of 16 items, consumed MSB first
- flag long 0x00000000: next 16 bytes are literals (decoder fast
  path: four longs verbatim)
- item tags:
    00  literal byte
    01  SHORT  `[-dist:u14][len-2:u2]`  len 3..5
    10  MEDIUM `[-dist:u12][len-2:u4]`  len 6..17
    11  LONG   `[-dist:u16][len-3:u8]`  len 6..258
- the distance word is always the negated distance; the decoder
  seeds the register with `moveq #-1` so tok bit15 sign-extends
  and `dst + tok` (after `asr` #2/#4 or none) reaches backward
- every 1x path reads a token word; a zero word terminates the
  stream under either flag (the packer emits flag 01 + zero word)
- medium/long copy counts come from the same jump-table code:
  field = (tok&15)+2 / byte+1, then field+2 bytes total

## Packer
- lazily AllocMem(0x80004) into xsp_Sub[0]: buf[0]=size;
  head[65536] ULONG at sub+0, chain[65536] ULONG at sub+0x40000
- hash key = `b0<<8 | ((b1+b2)&0xff)` -- `move.w`+`add.b`, third
  byte adds into the LOW byte only, no carry into b0's half
- head is indexed with a NEGATIVE register index off sub+0x40000
  (`d1 = 0xffff0000|key`, so d1.l*4 wraps back to sub+0)
- match walk: `dist = cur - cand` signed < 64 KB; quick-check
  `cur[best]==cand[best]`; verify 0..best-1 in CMPM.L blocks plus
  the byte tail, then extend to maxlen=min(258,remaining);
  strictly longer wins (nearest on ties)
- lazy pass: budget = `xsp_Mode/34` (cremation 33, ashes 67,
  oblivion 100 -> 0/1/2; LZW4 used /25 and four modes).  A probe
  adopts when `nlen - adv > best` (signed word), rewinds,
  literalises the gap; each gap literal is inserted AND ticks the
  flag counter.
- emit: packed `d5 = [dist:len]`; `swap+negw` gives the negated
  distance word; tier tests are UNSIGNED compares on that word
  (`cmpi.w #$bfff`/`#$efff` + bls): dist <= 16384 short (len<=5),
  dist <= 4096 medium (len<=17), else long.  Flag `tag<<bitpos`
  or'd in, bitpos -= 2 per item, flush at <0.
- output bound = outbuf + xsp_InLen (return -17); AllocMem
  failure -7; xsp_OutBufLen ignored; xsp_OutLen written.

## Decoder
- flag long MSB-first, 16 items; zero flag -> 16 literals
- copies use jump tables (`jmp (lab,pc,-field*2)`) entering an
  unrolled `move.b` sequence: short 3..5, medium/long field+2
- no bounds checks anywhere; no outlen writeback

## Source
`source/xpkLZW5.c`, `xpkLZW5_lib.s`, `functab_stub.s`,
`genfunctab.py`, `endmodule.s`, `Makefile`.

Verification: host model comparison -- the C encoder is
byte-identical to an independently derived model of the shipped
algorithm on every tested input/mode (50 KB+ mixed corpora at
budgets 0/1/2), including the defective tier-boundary tokens.
3000-trial suite: 1128 clean round-trips, 841 incompressible
-17s, 0 real failures; the rest decode to the shipped-format
corruption (see defects.md).
