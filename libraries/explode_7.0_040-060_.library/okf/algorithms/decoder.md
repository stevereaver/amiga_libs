# explode 7.0 decoder notes

Byte-identical algorithm to the 5.6.29 wedge (same packed format,
same tables), different code layout.  Transcribed verbatim into
`source/explode_lib.s`.

## Stream / control longs

The outer loop reads control longs forward from the ring copy:

- bit31 set -> advance to next output hunk (d5++), walk the BPTR
  chain, resume at its data start.  Reaching the output-hunk limit
  (a4+52) ends decoding -> free surplus hunks.
- bit30 set -> relocation item list: `count` long, then `hunkidx`
  long (low word indexes the seg chain), then `count` delta longs
  accumulated into d2; each adds the hunk base to `*(a3+d2)`.
- else -> copy run: the control long was left-shifted once for the
  bit30 test, so the count is `d0>>1` ring longs, moved 32 bytes per
  `movem.l (a2)+,d1-d7/a0` / `movem.l d1-d7/a0,(a1)` burst while a
  32-byte margin below the ring top holds, then a single-long tail.

## Bitstream

Backward byte stream (a0--), one carry-lane bit reader:
`add.b d1,d1` shifts a bit out; when the byte empties the next byte
is fetched and `addx.b` re-inserts the leftover carry, so bits are
consumed LSB-first across byte boundaries in reverse order.

Symbol decode (per block, counted in a4+4):

- bit 0 -> literal run header: d2 = length, copies a0-- bytes.
- 1x prefixes pick match length classes: `10`->2, `110`->3,
  `1110`->4, `11110`->5, `111110`->6+3 bits, `111111`->raw byte.
- distance: class index d3 (0-3); `0`->short (1 bit, d2=2*d2+bit),
  `10`->medium (d6=2 + tab1b bits), `11`->d6=tab1[class], then
  tab2[level] extra bits (bit7 of the table byte = take a raw byte
  instead); `+1` plus prefix/lensum base gives the back-distance.
- Ring: match source below ring bottom wraps by +d4; hitting the
  ring top while copying a match substitutes the ring bottom
  (a2) — sources may read bytes the decoder just wrote.

## Coroutine

`_exp7_rewind` is the only shared sub: wraps a2 to the ring bottom,
parks nothing but restores live state from the a4 frame, runs the
bit decoder until the ring fills (d5<0) or the block count runs out,
re-parks {resume-len, bitbuf, litrun} and `rts`s into whichever
inlined read site called it.  Six inlined hunk-walks and four inlined
ring-read sites total.

## Termination

After the last output hunk: walks from `count-1` (a4+52+1) down to
`count-2`, `FreeMem(size)` each surplus hunk (a1 = link-4 = alloc
base); final walk clears the last kept hunk's link long, terminating
the shortened chain.
