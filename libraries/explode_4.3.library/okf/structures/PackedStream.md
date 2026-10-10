# Packed stream / record format

Header (forward-read at blob start):
- byte0: hi nibble -> overrides tbl[11]; lo nibble = format 0..8
  (indexes a 12-byte distance table)
- byte1: bit-reservoir seed
- word : initial literal count
- long : block count (negative => range[i] built as (1<<bits)-1)

Body: read BACKWARD from blob end.  MSB-first bits; literal runs and
LZ matches alternate; after each match a new literal count is read.

Tag records in the DECOMPRESSED stream (4-byte granularity):
- negative long: end of current segment -> advance to next
- bit30 set: relocation group {count, target-seg-idx, delta offsets}
- zero: skipped
- else: 4 payload bytes written to the segment base

Ring: `ring_sz = hunk_size - 8` bytes in the LAST hunk; pull cursor
and write cursor both move downward; refill when pull reaches low
bound.  Match sources wrap at the low bound to the ring top.
