# XpksPackChunk (LVO -36)

PackBits-style run-length encoder.

## Stream format

```
<code><lit bytes>     1 <= code <= 127    literal run of <code> bytes
<code><byte>        -127 <= code <= -1    repeat run of <-code> bytes
0x00                                   stream terminator
```

## Register model (shipped asm)

- `a5` src cursor, `a4` literal base, `a3` srcend = InBuf + InLen
- `a2` out cursor, `sp@(32)` dstlim = OutBuf + **OutBufLen**
- `d7` run flag / run length, `d6` literal length
- `sp@(36)` saved params pointer (for the OutLen write-back)

## Algorithm

1. At the loop top, read `src[0..2]` **unconditionally** — a run is
   flagged when all three are equal (out-of-bounds reads once fewer
   than three input bytes remain; see findings).
2. Capacity check, evaluated every iteration: continue only when
   `out + litlen + 4 < dstlim`, else return `XPKERR_EXPANSION (-17)`.
3. Emit a literal token when a run was flagged, when `litlen == 127`
   (hard cap), or when `src == srcend`.  Literal code = length
   (1..127), followed by the literal bytes.
4. No run flagged → `src++` and loop (literal scan, one byte at a
   time, re-testing for a 3-byte run at every position).
5. Run flagged → extend with `d7 = 3`: while `src+d7 < srcend` and
   `src[d7-1] == src[d7]` and `d7 < 127`, increment `d7`.  Emit
   `-d7`, `src[0]`; `src += d7`; literal base = new src.
6. When `src == srcend` after a literal emit, write the `0x00`
   terminator, store `xsp_OutLen = out - OutBuf`, return 0.

## Deltas vs v1.5

- Output bound is `OutBuf + xsp_OutBufLen` (v1.5 uses InLen).
- Literal cap is a hard 127 (v1.5 has a 124/125 lookahead budget).
- Run detect at the loop top re-reads `src[0..2]` every step;
  v1.5 carries the two lookahead bytes in registers.

## Defects (see findings/)

- `src[0..2]` reads past the input end on every tail iteration.
- A false 3-equal detect over the end boundary makes the encoder
  emit a run token that consumes bytes past `srcend`, after which
  `src` overshoots and the scan runs away unboundedly.
- `n = 0` still reads 3 bytes past the (empty) input and emits a
  1-byte stream (`0x00` terminator, OutLen = 1).
