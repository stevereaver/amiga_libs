# xpkZENO 1.2 — defects and quirks

All reproduced faithfully in the reconstruction.

## Shipped quirks

1. **Dictionary never issues the top code.**  Insertion stops
   when `nextcode == (1<<bits)-1`, so one dictionary slot is
   permanently wasted (codes `mask-1`/`mask` unreachable as
   entries; `mask` itself collides with the emitted range).
   Matches the "one slot early" LZW variant.

2. **Rehash restart offset.**  After a collision on the primary
   hash slot, the probe restarts at `0x7ff + (byte<<(bits-8))`
   rather than at the primary `h` — equivalent modulo the table
   bound, but a distinctive idiom.

3. **Modulus table read past the used range.**  Per-width rehash
   moduli (0x1003/0x2011/0x47fb) live in a literal word table in
   the code stream; a fourth entry (0x87f7, for 15 bits) is
   present but unreachable since modes cap at 14 bits.

4. **Unused codes.**  0x102 and 0x103 are never emitted;
   `nextcode` starts at 0x104, leaving a two-code hole.

5. **`xsp_Password` dereferenced unconditionally** in
   `XpksPackChunk` (`tst.l (a1)`) — a NULL password pointer
   would bus-error.  Latent: the XPK master always passes a
   string buffer.

6. **`xsp_InLen` never checked by the unpacker.**  A truncated
   stream reads past the input until 0x100 appears or the output
   buffer fills — silent garbage rather than an error return.

7. **Stream `bits` byte trusted.**  The unpacker sizes its
   tables from the stream header's width byte; a malformed
   header (>14) would write past the allocated workmem.

8. **Output budget = input size.**  `XpksPackChunk` fails -17
   once emitted longs reach `outbuf+inlen`, so the library
   refuses any expansion — correct XPK convention, but means
   incompressible input packs nothing.

9. **Adaptive reset threshold is asymmetric.**  Reset fires on
   `delta >= prev_delta + 128` (bytes per 1024-input window).
   `thresh` is set to `0xfffff` after a reset, so the window
   right after a reset can never trigger another one.
