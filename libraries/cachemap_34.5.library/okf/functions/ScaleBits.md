---
type: Function
title: ScaleBits
description: Nearest-neighbour replication of a bit stream (Bresenham).
lvo: -72
registers: d0 nsrc, d1 ndst, a0 src, a1 dst
timestamp: 2026-10-10T19:30:00Z
---

# ``void ScaleBits(ULONG nsrc, ULONG ndst, void *src, void *dst)``

**LVO -72**

Stretches `nsrc` MSB-first source bits to `ndst` MSB-first output
bits by integer replication: `divu` gives quotient + remainder;
each source bit is emitted `quot` times, plus once more whenever
the Bresenham error accumulator (initialised to `-nsrc/2`) crosses
zero.  Works for up- and down-scaling (rep == 0 drops source bits).

Source bits are consumed one per outer iteration, refilling a
32-bit register from `src` every 32 bits; output accumulates in a
32-bit register flushed to `dst` whenever full.  A final partial
long is aligned and stored as one word when `ndst mod 32` < 17,
else a full long.  All registers except d0/d1/a0/a1 are preserved;
return value is unspecified.
