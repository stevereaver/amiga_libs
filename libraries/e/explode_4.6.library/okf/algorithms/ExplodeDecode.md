# Explode decode algorithm

Two-level structure: a bit-level LZSS engine emits decompressed bytes
into a small ring buffer, and a record driver pulls tagged 4-byte
records out of the ring and applies them to the output hunks.

## Bit reader

MSB-first reservoir in D1, one byte at a time.  `add.b d1,d1` emits
the carry; when the register drains to zero the next byte is loaded
and shifted in with a `+1` sentinel - the emitted bit on a refill
step is the NEW byte's MSB (the sentinel bit is consumed, not
emitted).

## Token stream (descending reads)

Each block: pending literal run, then one match.

- literal run: `litcount` bytes copied 1:1 from the stream (backward).
- match length prefix code:
  `0 -> 2 | 10 -> 3 | 110 -> 4 | 1110 -> 5 |
   11110 + 3 bits -> 6..13 | 11111 + 1 raw byte -> 0..255 (0 = 256)`
- next literal-run count (also the distance low bits):
  `0 + 1 bit | 10 + tbl[4+cls] bits + 2 |
   11 + tbl[8+cls] bits + tbl[cls]`
- distance high bits:
  `0 -> 0 | 10 -> range[cls] | 11 -> range[4+cls]`, then
  offbits[cls|+4|+8] extra bits (bit7 of the table entry means
  read one raw byte first), +1; source = wpos + sext(base) + sext(v)
  wrapping inside the ring.
- the block counter (frame +4) decrements per match; its sign bit
  folds -1 into every range entry at setup.

## Ring and record driver

Ring = last hunk's data area (hunk_size-8 bytes).  Output is written
downward from the ring top; the pull cursor chases it downward and
rewinds to the top on wrap.  Records (4 bytes, pulled downward):

- `<0` : segment separator - end of current output hunk
- bit30 set : relocation group `{count, target-seg, delta*}`
  applied in place: `*(segbase+off) += chaindata(seg)`
- `0` : skipped
- other : payload longword stored at the current segment base

Teardown frees the last two chain hunks (packed data + ring), clears
the link word of the new tail and returns chain+4 as the entry point.
