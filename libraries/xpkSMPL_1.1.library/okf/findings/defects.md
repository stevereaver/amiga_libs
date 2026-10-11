# defects / quirks

1. **Length-0 symbols desynchronize the stream (critical).**
   For every symbol absent from the delta histogram the length-table
   loop executes `subq.b #4,d6` (advance the bit-space counter by 4
   WITHOUT the usual flush check) followed by `moveq #0,d7`, which
   wipes the ENTIRE bit accumulator including real pending bits.
   The emitted nibble positions therefore no longer line up with the
   reader's model whenever pending bits existed at the moment of the
   wipe.  Consequence: the packer produces a *decodably corrupt*
   stream for any input that does not use all 256 distinct byte
   deltas; only inputs whose delta histogram covers all 256 symbols
   produce valid streams.  Decoding a corrupt stream makes the
   unpacker follow garbage trie links and read/write outside the
   workmem -- on real hardware this is a memory-corrupting wild
   pointer walk.  Reproduced verbatim (host-verified byte-identical
   corrupt output).

2. **`space` is a byte-sized counter.**  `subq.b`/`add.b`/`sub.b`
   on d6 -- the free-bit count wraps modulo 256 and the flush check
   is the byte-borrow flag, not a signed-integer test.

3. **`lsl` count wraps mod 64.**  `lsll d6,d0` with a (byte-wrapped)
   space value outside 0..32 shifts by `space & 63`; values >=32
   produce d0=0 -- the code OR contributes nothing.  Only reachable
   via the corrupt-stream paths of defect 1.

4. **Input length tested/word-counted, not long.**
   `lsrw #1; subqw #1; bcs` on the long: the packer rejects when the
   LOW WORD of inlen is < 2 (so 0x10000 fails the check although it
   is a legal buffer size); the histogram and data loops then run
   `inlen & 0xffff` iterations (0 wraps to 0x10000).  An inlen of
   0x10000+k packs only k samples' deltas.

5. **len >= 31 is unencodable.**  `(len-31)&0xff` in 8 bits gives
   0x00 for len 31, which the decoder reads as "symbol absent" --
   degenerate (>30-bit) Huffman trees produce desynced streams.
   Practically unreachable for <=256 symbols unless the histogram
   is Fibonacci-skewed.

6. **Decoder overreads the compressed tail.**  `movew a6@+,d7`
   refills up to 2 bytes past the stream end; the packer appends a
   4-byte pad long to cover it.  Callers must place the input so 2
   trailing bytes are readable.

7. **Decode count wraps as word.**  `subql` then `subqw #1; bccs`
   on outlen: the output count is `1 + (UWORD)(outlen-1)` -- outlen
   0x10001 decodes 1 byte, outlen 0 decodes 0x10000 bytes.

8. **Single-symbol tree uses the sentinel slot.**  With exactly one
   nonzero histogram entry, the merge loop's single-node path gives
   the leaf edge 0x4000 and parents it to the sentinel arena slot
   (which keeps n_sym=0xffff); that still desyncs downstream because
   of defect 1 (255 absent symbols).

9. **Two different emit paths.**  The lens-table 8-bit "extended
   length" encoding is an inline copy of the writer; the data-code
   emit at 0x3ec splits len>=16 into two <=16 emits.  The lens-table
   *code* portion uses the shared 0x3ec routine (with the split) --
   not the inline one.
