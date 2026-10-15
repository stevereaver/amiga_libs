---
type: Algorithm
title: WordByte/ByteByte window scanner
---
# WordByte/ByteByte window scanner

Shared register machine for the 2- and 1-byte count paths.

- `d2` = window budget, decremented once per MATCHED scan
  position; initial value is the full window (32767/127)
  regardless of input size.
- `d7` = consumed (emitted) position counter.
- `d4` = pending literal length, `d6` = current run length,
  `d3` = run byte, `a1` = scan cursor, `a2` = literal head.
- After each emitted item the window refills:
  `d7 < a5` -> `d2 = win`, else `d2 = a5+win-d7`
  (a5 = inlen-1-win).  `d2 <= 0` ends the pack.

Item scan: seed `d3 = *a1` (no cursor advance), then a
dbne-style match loop — mismatch or window exhaustion
breaks it, `a1--` unreads the fail byte, `d6` holds the
match count.  `d6 < minr` absorbs the item into the
pending literal (seed folds via `d4 += d6` at loop top);
else the literal block flushes (`-(d4-1)` count + data)
and the run emits (`d6-1` count + byte).

Consequences (all reproduced):

- Inputs smaller than one window: the FIRST pass still
  scans `win` positions — running past the input end —
  and whatever memory follows is compressed and emitted.
  Decoded output then exceeds the input length.
- Final byte is dropped whenever it is the terminator
  byte of a qualifying tail run (`d7 >= inlen-1` exits
  before it can seed an item).
- Empty input emits a 1-byte run of `inbuf[0]` (OOB).
