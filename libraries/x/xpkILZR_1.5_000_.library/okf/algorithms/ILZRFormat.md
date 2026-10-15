---
type: Algorithm
title: ILZR bit-stream format
---

# ILZR stream format

```
stream = outlen:u16be  { token }*  pad-to-byte
token  = '1' byte:u8                  literal   (9 bits)
token  = '0' pos:u(w) (len-3):u4      match     (5+w bits)
```

Bits are written MSB-first.  The pending partial byte is
kept *in the output stream* at the write cursor (the
original does `move.b (a6),d2; lsl.l d1,d2; or.l d0,d2`),
so each token shifts the residue left and merges.

`pos` is an ABSOLUTE output index — the decoder copies
`len` bytes starting at `out[pos]`, not `out[cur-pos]`.
Width `w` = bits needed for the largest representable
position so far: it starts at 8 and the decoder bumps it
each time `written > (1<<w)` — i.e. w=8 while out<=256,
w=9 for <=512, etc.  The encoder uses the same rule on the
input cursor.  Because positions equal the scan offset,
out-index == in-index (emission is aligned with scanning).

`len` = 3..18 (4-bit field +3; the match scan caps at 18
cmpm bytes).  `rem<3` tails and `len<3` candidates emit
literals.

## Bound behaviour

- pack writes the byte THEN checks `a6 < out+inlen`; the
  boundary byte is already stored when -17 returns, and
  the final pad byte is not checked at all.
- unpack writes exactly `outlen` bytes; a terminal match
  longer than the remaining count overwrites (no bound).
- unpack compares the stream's outlen word against the
  caller-preset xsp_OutLen -> -14; it never *writes*
  xsp_OutLen itself.
