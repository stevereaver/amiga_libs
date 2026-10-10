# XpksUnpackChunk (@0x31c) -- decoder

`a0 = InBuf`, `a1 = OutBuf`, `d1 = -1` (moveq),
`d4 = 7` (mod-8 mask).

## Flag groups

Read 4 bytes BE into d2.  If d2 == 0 -> 32 literals via an
8x-unrolled `dbf` loop (the decoder fast path).  Else 32
items, LSB first: `lsrl #1,d2` -> carry set = match,
clear = literal byte.

## Literal

`moveb a0@+,a1@+` -- one raw byte, no check.

## Match

- `d1 = (a0@+<<8)|a0@+` -- the token word; note d1's UPPER
  word retains `moveq #-1`, so d1.l = 0xffffXXXX.
- `tstw d1; beq -> end` -- the 0x0000 terminator.
- `a2 = a1 + d1.l` = a1 + (tok - 0x10000) = a1 - dist
  (the sign-extension trick; works for all dist 1..0xffff).
- `d1 = a0@+`; `beq` skips the unrolled prologue when the
  count is a multiple of 8; `d1 += 4` -> len = byte + 4.
- `d3 = d1 & 7`; `lsrw #3` -> full-block count; computed
  `jmp pc@(0x398,d3:w)` enters the 8x-unrolled
  `moveb a2@+,a1@+` loop at the right offset; `dbf d1`
  finishes the blocks; `dbf d0` iterates the flag bits.

## End

Token word 0 -> `moveml sp@+,d2-d4/a2; moveq #0,d0; rts`.

## Notes

- NO input bound check: trusts the flag stream.
- NO output bound check: trusts InLen.
- `xsp_OutLen` is NEVER written (unlike most siblings).
- All byte ops -- this one genuinely runs on a 68000
  (unlike V3.3's unaligned word stores).
