# xpkFAST 1.2 — quirks & defects

All reproduced faithfully in the reconstruction.

1. **Crawler can never emit len 18.**  The compare chain is 17
   `cmpm` instructions and `len` = compares executed, so a full
   run yields 17 for an 18-byte match.  The `best >= 18`
   early-exit (`cmp.w d3,d5;bcc`) is dead code.

2. **Crawler trusts byte 0.**  The full compare starts at byte 1;
   byte 0 is assumed equal because the hash matched.  A hash
   collision (h16 = (b0<<8)|((b1+b2)&0xff) ignores b0's low byte
   collision potential) can emit a match whose first byte is
   wrong — the stream is still self-consistent for the decoder,
   it just decodes different bytes than the input.

3. **PackReset leaves the chain table stale.**  Reset clears
   `(Sub[1]+1)*0x10000` bytes from Sub[0] — the crawling chain
   table at Sub[0]+0x40000 is never cleared.  Repacking after a
   reset can chase links into positions from the previous pack.

4. **Signed offset test.**  `src - cand` is tested with a signed
   `bgt #0xfff` — a stale candidate pointer *ahead* of src
   yields a negative offset that passes the window check, so the
   compare runs against out-of-range data (result usually
   len<3, harmless but wasteful).

5. **Input overrun reads.**  Hashing the last positions reads
   `src[0..2]` past `inbuf+inlen`, and the compare chains read
   past the buffer end; bytes there affect only table
   contents/compare outcomes for truncated `left` cases.

6. **Mode select is unsigned.**  `xsp_Mode` is compared with
   `bcc` — negative mode values select the crawling packer,
   not the speedy one.

7. **Tail copier drops odd byte.**  The bit-cascade copier
   emits `size & ~1` bytes — an odd-sized backward region would
   lose its last byte (unreachable in practice: all writes are
   words).

8. **Unpacker trusts the stream.**  No bounds checking: a
   corrupt stream can read/write outside both buffers; match
   copies can reach before OutBuf (negative source) and past
   any output bound — the loop ends only when the literal and
   ctrl cursors meet.

9. **Unpacker DBF/16-bit limits** — none observed here; the
   match copy is a fully-unrolled 18-byte jump table, and the
   literal path is per-byte, so no 16-bit wrap quirk like
   xpkSMPL's.

10. **Linker tail garbage.**  The original code hunk ends with
    `00 21 e2 34` after "Decompressed\0" — reproduced verbatim
    by `endmodule.s`.

## Reconstruction notes

- The decoder's sentinel-in-X (`addx`) idiom means a control
  word whose low bits are all zero still yields exactly 16
  items: reload consumes bit15 of the fresh word and injects
  the sentinel at bit0; the sentinel's carry-out (with the
  register left at 0) marks exhaustion, not an item bit.
  A naive `!bits` reload check on the raw word misfires on
  zero-tailed words (the original failure mode during RE).
