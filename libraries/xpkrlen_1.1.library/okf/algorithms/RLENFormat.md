---
type: Algorithm
title: RLEN stream format
---

# RLEN stream format

```
stream = { token }* 00
token  = n(>0)   byte*n      literal run: copy n bytes
token  = n(<0)   byte        byte run:     replicate -n times
token  = 0                   terminator
```

Both literal runs and byte runs are capped at 127 (the
count is a signed byte; -128 is never emitted because the
run cap is 127).

## Packer

Two cursors: `cur` (scan) and `lit` (literal-flush).  Each
iteration reads `in[cur]`,`in[cur+1]`,`in[cur+2]` — a run
starts when all three are equal (reads past InLen at the
tail; the values only gate the run branch).

Pending literals `n = cur - lit` are flushed (`<n><bytes>`)
whenever a run starts, `n` reaches 127, or input ends — the
input-end case also appends the `0` terminator and stops.

Run extension: starting at `rl=3`, check
`in[cur+rl] == in[cur+rl-1]` for the CURRENT `rl` before
incrementing — i.e. the run is a contiguous run of equal
bytes, extended one position at a time, capped at 127.
Emitted `<-rl><in[cur]>`.  Both cursors advance to `cur+rl`.

## Bounds

- pack checks `out + lit + 4 <= cap` before flushing — the
  4 covers the count byte, the 2-byte run token, and the
  terminator.  The run emit itself is unchecked.
- unpack has NO bound check; negative counts replicate
  blindly.  xsp_OutLen is never written by the decoder.
