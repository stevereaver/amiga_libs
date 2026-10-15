# xpkTDCS — shipped defects

1. **PackReset underflows the allocation by ~20KB.** The movem
   fill writes 70,577 longs (282,308 bytes) downward from
   `sub+0x40000`: it clears all 65,536 head entries and then
   keeps writing 20,164 bytes below the start of the
   0x80004-byte workmem block. Whatever the user allocated
   immediately before the workmem gets zeroed. The chain ring
   at sub+0x40000 is never cleared (harmless — dist ≥ 64KB
   stops the walk). Reproduced verbatim in XpksPackReset.

2. **Self-corrupting tier-boundary tokens.** The emit picks the
   short tier when `ndist > 0xbfff` (dist ≤ 16384), but the
   packed field `ndist << 2` only survives 14 bits: distances
   8192..16384 emit token words whose sign bit is shifted out,
   decoding as positive/short distances → corrupt output.
   Same for the medium tier: `ndist > 0xefff` allows dist 4096,
   and `(0xf000 << 4)` = 0 → decodes as dist 0 field. Roughly
   a third of randomized inputs hit this. Reproduced verbatim.

3. **No terminator check under 01/10.** Only the flag-11 path
   tests the token word for zero; a zero word under flag 01/10
   is decoded as a real token (dist 0/len 3 or dist 0/len 3).
   A truncated/corrupt stream desyncs rather than stopping.

4. **Decoder has no bounds checking.** Copies are unbounded —
   corrupt distances read/write outside both buffers; no
   outlen writeback, no error return possible (always 0).

5. **insert() reads past the input end.** The `remaining < 3`
   guard is checked once for a whole inserted tail, so a match
   ending in the last 1-2 bytes inserts them anyway, reading
   up to 2 bytes past the caller's buffer.

6. **Unbounded chain walk.** find() has no iteration cap —
   pathological inputs (e.g. a repeated 3-byte key) make pack
   quadratic. ("slow packing" is literally in the description.)

7. **68020 gate only at init.** LibInit checks AFB_68020, but
   nothing in the codec needs 020 — it's purely a marketing
   tag. Works fine if force-loaded on a 68000.
