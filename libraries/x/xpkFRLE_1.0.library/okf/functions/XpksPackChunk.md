---
type: Function
title: XpksPackChunk
description: FRLE encoder — 4-phase literal scanner plus unrolled run counter.
lvo: -36
registers: a0 XpkSubParams *, a6 base -> d0 0 / -17
---

# ``LONG XpksPackChunk(struct XpkSubParams *p)``

**LVO -36** (hunk +0x116)

Reads `xsp_InBuf`/`InLen`/`OutBuf`/`OutBufLen`, writes
`xsp_OutLen`.  Output bound: `OutBuf + OutBufLen`.
Returns 0, or -17 (XPKERR_EXPANSION) when the output buffer is
too small.

## Head check

At every segment start the first two bytes are compared
unconditionally (`move.b (a1)+,d0 / cmp.b (a1)+,d0`).  Equal ->
run path; different -> literal path.

## Run path (2+ equal bytes)

- 15 + 7*16 = 127 further `cmp.b (a1)+,d0` compares in an
  unrolled block (d3=7 dbf over a 16-compare body entered at its
  second instruction) -> run length <= 129, the format maximum.
- Emits `(n-2)^0x9f`, byte.  Only *one* byte of output headroom
  is tested before writing two.
- If the scan pointer passed `srcend`, `n` is clamped to
  `srcend - lit` before emission (and a zero clamp ends packing).

## Literal scanner (four-phase machine)

A sliding one-byte window (d0/d1) checks consecutive pairs; on
an equal pair a confirm read checks for a third equal byte.
Three equal bytes end the literal three bytes back (the run is
re-detected by the head check on the next iteration).  The loop
budget d3=31 is decremented once per machine cycle at three
exit points (L1-fail, P3-fail, P4-fail); P4-fail additionally
retreats `a1` by one on exhaustion.

Reads per budget cycle are 2..5 depending on the phase path;
the worst case lands on exactly 128 emitted literal bytes — a
deliberate fit to the `(len-1)^0x1f` header maximum (see
algorithms/FRLEFormat.md).

- Capacity check uses the *unclamped* scanned length:
  `out + litlen + 1 >= dstlim` -> -17.
- If the scan pointer passed `srcend`, `litlen` is clamped to
  `srcend - lit` (zero ends packing); the clamped literal is
  emitted as `(len-1)^0x1f` + data.

All input reads past `srcend` are unconditional in the
original; the reconstruction bounds them (see
findings/EncoderDefects.md).
