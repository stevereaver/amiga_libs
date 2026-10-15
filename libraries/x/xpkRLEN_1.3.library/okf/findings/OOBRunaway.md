# Encoder out-of-bounds reads and runaway scan

`XpksPackChunk` reads `src[0]`, `src[1]`, `src[2]` at the top of
every loop iteration to detect a 3-byte run — with no check
against `srcend`.  Consequences:

1. **Always reads past the end.**  For the last two input bytes the
   third byte of the probe is already out of bounds; for `n < 3`
   (including `n = 0`) the whole probe is out of bounds.

2. **False run over the boundary.**  If `src[srcend-2]` ==
   `src[srcend-1]` == the byte at `src[srcend]` (out of bounds),
   the encoder emits a run token and does `src += 3` — landing
   *past* `srcend`.  From then on `src == srcend` can never be
   true again: the literal scan (`src++` per iteration) marches
   forward without bound, reading and copying memory until the
   capacity check (`out + litlen + 4 < dstlim`) or the 127-byte
   literal cap forces emits — corrupt output, and reads can walk
   off the allocation entirely.

3. **Spurious run token.**  Even when the run is terminated by the
   `src + d7 >= srcend` bound, a false-boundary run emits
   `-d7, src[0]` covering bytes the caller never supplied — the
   decoder then produces garbage tail bytes.

The same class of defect exists in xpkCBR0 1.1 (one-byte
over-read, AMIGALIBS-26) and xpkFRLE 1.1/1.2 (OOB-derived tail
literals, AMIGALIBS-28), but the RLEN 1.3 variant is worse: the
overshoot converts a bounded over-read into an *unbounded* one.

Observed in host testing: ASan-flagged read past a 64 KiB input
buffer on inputs whose tail bytes collided with the padding —
the reconstruction reproduces the shipped data flow exactly.

The reconstruction keeps the same data flow (unconditional
`src[0..2]` probe, `src += run` overshoot) so behavior matches
the shipped binary for all inputs where the bytes after the
buffer differ from the tail bytes.
