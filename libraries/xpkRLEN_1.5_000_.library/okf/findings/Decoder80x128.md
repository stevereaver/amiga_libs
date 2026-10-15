# Decoder 0x80 token emits 128 bytes

The 1.5 decoder dispatches on `bmi`/`beq`/`bne`.  A 0x80 token takes
the run path: read the next byte, `neg.b` the count — which stays
-128 — then `move.b/subq.b/bne` loops until d0 hits 0.  -128 counts
down through -1, wraps to +127 and down to 0: the byte is emitted
**128 times**, the maximum possible run.

Harmless for conforming streams (the encoder never produces 0x80 —
the dbra run-scanner caps emitted runs well below -128), but it's the
opposite quirk of 1.4, where the same token emitted the byte exactly
once (that decoder's `bgt` loop died on the neg.b/subq.b overflow).
Verified in `work/oracle.py`: `80 'Q'` produces 128 'Q' bytes.
