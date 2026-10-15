# Decoder — backward bitstream LZ + canonical lengths

Control block at hunk+32 (a5):

    byte0  hi nibble -> frame+19 (extra bit count)
           lo nibble -> tab2 record index (x10 stride)
    byte1  initial bit-buffer byte
    word2  literal-run count
    long4  block counter (bit31: len bases get -1)

Two streams: a2 reads the FORWARD control stream inside the last
hunk's ring buffer; a0 reads the BACKWARD bit/literal stream from
the packed region. The ring wraps by d4 (last-hunk size-8).

## Control stream (forward longs)

- `d0 < 0`        next output hunk (hunkwalk d5 -> a3)
- bit30 set       relocation item: d1 longs of delta-encoded
                  offsets; `*(a3+d2) += target_hunk_base`
- else            literal run of d0>>1 longs copied ring->output
                  (8-long movem burst, 32B wrap margin)

## Bit reader (backward, addx-sentinel)

`add.b d1,d1` shifts the buffer; when it empties `move.b -(a0),d1;
addx.b d1,d1` injects a byte with the X flag as sentinel — same
scheme as the xpk family, exhaust == shift-out with zero.

## Symbol decode (per block)

1. unary length class: 0->2, 10->3, 110->4, 1110->5,
   11110->6+3bits, 111110->6+raw byte, 111111->raw byte length;
   class index in d7 (0..3 table classes).
2. distance: 0 -> short (d2 = 2*d2+bit); 10 -> d6=2 base +
   tab1b bits; 11 -> d6 = tab1[class] base + tab1b[class+4] bits.
3. second bit: 0 -> a5 = lensum[class*2] (+4 to d7); 10 -> prefix
   base (+8); then tab2rec[d7] extra bits (bit7 -> literal byte +
   &127 count); distance = d6+a5+1.
4. match source = a3 - dist, ring-wrapped by d4; ring-top check
   inside the copy loop swaps source to the read pos.

The coroutine parks {litrun, bitbuf, resume, blocks} in the frame
when the ring fills mid-symbol and resumes on the next refill.
