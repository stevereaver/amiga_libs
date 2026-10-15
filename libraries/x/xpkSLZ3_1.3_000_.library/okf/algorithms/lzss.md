# SLZ3 -- "Simple & Fast LZSS"

FastLZ-family encoder: single 16-bit hash of 3 bytes ->
last-seen position, plus a 4096-entry ring chaining each
position to the previous holder of its hash.  Walk the chain
for the best match; accept immediately at len 17 (max), else
emit the best >= 3 after the chain exhausts or dist > 4095.

```
stream  = [flag][items]... [0x00]
flag    = byte, MSB first, 1 = match / 0 = literal,
          precedes the 8 items it describes
literal = 1 raw byte
match   = [dist_hi4 | len-2][dist_lo8]
          dist 1..4095, len 3..17
end     = flag pad bits (one 1 then 0s) + a 0x00 token byte,
          consumed by the decoder as match -> byte 0 -> stop
```

Encoder hash: `(b0<<8) | ((b1+b2)&0xff)`; equal hashes imply
equal first bytes, so the match compare starts at byte 1.

Performance profile: O(n) seeds + bounded chain walks
(chain degrades gracefully through ring collisions);
~540 KB workmem is large for 1994, matching the "fastLZ"
name -- speed over memory.

## Notable implementation details

- `moveq #-1` sign trick makes the 256 KB hash reachable
  through the same `a5` base as the 16 KB chain ring.
- Best-match bookkeeping keeps [dist:len] packed in one
  register pair (d5 swap) so the emit path needs no memory.
- The flag byte is reserved in-stream before its items --
  zero lookahead buffering on output.
