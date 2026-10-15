# xpkRDCN 2.4 — Bitstream Format & Decoder

## Stream layout

```
[ctrl word BE][16 tokens][ctrl word BE][16 tokens]...
```

Control word = 16 items, MSB first. Bit set = compressed token,
bit clear = literal byte. The final group may be partial; when a
group ends exactly on the 16th item the packer rewinds the empty
reserved ctrl slot (crawler), or emits a trailing 0x0000 word
(speedy) which the decoder reads then discards via the end check.

## Token formats (first byte b; hi = b>>4, lo = b&0xf)

| hi | Class | Bytes | Decode |
|----|-------|-------|--------|
| >=3 | MATCH2B | 2 | len=hi (3..15); dist = (lo \| next<<4) + 3 |
| ==2 | MATCH3B | 3 | len = next2 + 16 (16..271); dist = (lo \| next<<4) + 3 |
| ==0 | RLE2B   | 2 | byte v = next; write v x (lo+3) (len 3..18) |
| ==1 | RLE3B   | 3 | L = lo \| (next<<4); byte v = next2; write v x (L+19) (len 19..4114) |

Match distances encode `dist-3`, so real distances are 3..0x1002
(12-bit field + 3).

## Decoder (XpksUnpackChunk, orig 0x504)

- `a1=in, a3=in+inlen, a2=out; d4=4` (nibble shift count).
- Ctrl load: two `move.b (a1)+` into a word = BE; `d3=15` bit index.
- `cmpa.l a3,a1; bge -> return 0` after each load — input exhaustion
  check happens only at ctrl reload, never per item. Items can read
  past the input end (faithful trailing garbage).
- MATCH2B: `a0 = a2-3-lo-(next<<4)`; copies hi bytes
  (`copy 1 + dbf hi-2`).
- RLE2B: writes 2 + dbf(lo) = lo+3 bytes.
- RLE3B: computes L = lo + next<<4, then an optimized bulk fill:
  optional pre-byte if `a2` odd, unconditional 18-byte burst
  (4 longs + 1 word) of the quadrupled run byte, then (L>>2) longs
  and (L&3)+1 bytes — total L+19 writes. Reconstruction uses an
  equivalent simple loop (identical output).
- MATCH3B: dist = lo+3+next<<4, len = next2+16. Overlapped-copy
  fast path: if dist even and src aligned, 4-byte movem copies
  ((len+1)>>2 longs + remainder bytes); else pure byte loop.
  Reconstruction uses the byte loop (identical output).
- Returns 0 unconditionally. No output bounds checking.
