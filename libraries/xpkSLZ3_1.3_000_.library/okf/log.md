# Log

## 2026-10-10T16:05:00Z -- reconstruction complete

- Parsed single-hunk xpkSLZ3 1.3 (000) by Niels Froehling:
  RomTag AUTOINIT v1, InitTable@0x64 (dataSize 0x26),
  word-offset functab@0x94, static descriptor@0x368.
- Decoded the full codec: greedy FastLZ-family LZSS with a
  64K-entry hash + 4096-entry pos&0xfff chain ring in a
  278,532-byte workmem; interleaved MSB-first flag bytes,
  match tokens [dist_hi4|len-2][dist_lo8], 0x00 terminator.
- Identified the moveq #-1 negative-index trick that lets
  sub+0x40000 index the hash table at sub.
- Found PackReset's ~15 KB heap underflow, the uninitialised
  chain ring, OOB input reads, post-write output bound,
  and OutLen/double-free quirks.
- Reconstructed in C (+ two-pass word-offset functab);
  306 host round-trips pass, 220 expansion rejects.
  The emit-path fix: distance must come from the BEST
  candidate pair, not the exhausted chain pointer.
