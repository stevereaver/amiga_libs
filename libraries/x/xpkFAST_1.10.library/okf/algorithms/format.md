# xpkFAST 1.10 stream format

**Identical to 1.06** — the speedy packer (code+0x138),
crawling packer (code+0x358), and decoder (code+0x51a) are the
same instruction sequence as `xpkfast_1.06.library`, differing
only in assembler spellings (`addw d0,d0` twice where 1.06 has
`aslw #2,d0`, `cmpib` vs `cmpb`, etc.).  See
`xpkfast_1.06.library/okf/algorithms/*.md` for the full bit-level
write-up.  Summary:

```
[ literal bytes ... ][ pad ][ backward region ]
```

- Literals appended forward from out+0.
- Control words + match tokens are big-endian words pushed
  downward from:
  - speedy:   `ctop = (out + InLen) & ~3`  (absolute alignment)
  - crawling: `ctop = out + (InLen & ~3)`
- Flag word = 16 items, MSB first: 0 = literal, 1 = match.
- Token = `(offset<<4) | nibble`; decoder len = 18 - nibble
  (3..18); offset 1..0xfff.
- Speedy: single-candidate stateful 16-bit hash over the 3-byte
  gram, window 4095, head phase (bound check only at flag-word
  completion) + tail phase (last 288 bytes, per-item check).
- Crawler: `(b0<<8)|((b1+b2)&0xff)` gram -> 64K hash heads via
  the `0xffff0000`-biased long index onto work+0x40000 base;
  4096-entry position-indexed chain table; greedy longest-match
  walk, compare counts the failed byte (lf = equal+1).
- Finish: gap check (`cw - o < 0` -> 0 -> wrapper -17),
  `(gap&3)` zero pad bytes, control block compacted down with a
  longword copy behind the literals.
- Packer fourth arg d1 = 90 is vestigial (never read).

## Verified

37-case Musashi oracle regression (randomized compressible
inputs, modes 0..100 incl. the 79/80/81 boundary, incompressible
streams -> -17 collisions, unpack round-trips): packed streams
byte-identical to the original, workmem size/alloc/free sequence
identical, descriptor fields identical.
