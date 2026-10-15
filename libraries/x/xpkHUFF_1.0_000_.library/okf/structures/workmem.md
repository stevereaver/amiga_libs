# xpkHUFF 1.0 — structures

## Library base

Standard AutoInit lib (datasize 0x26).  `+34` = seglist
(stored by LibInit, used by LibExpunge).

## Pack workmem — `AllocMem(0x3208)`, body = alloc+4

| off (body) | size    | use                                        |
|------------|---------|--------------------------------------------|
| +0   ..+3  | 4       | saved SP — emit-bailout longjmp target     |
| +4   ..+7  | 4       | node-arena list head (ptr)                 |
| +8   ..+25 | 18      | scratch / merge-buffer nodes               |
| +26  ..    | 11242   | node arena — 22-byte nodes                 |
| +11268     | 512     | `lentab[256]` u16 (reuses histogram space) |
| +11780     | 1024    | `codetab[256]` u32 right-justified         |
|            | 0x3204  | body total (alloc prefix +4 -> 0x3208)     |

Node (22B, `struct pnode`): `link@0:4`, `freq@4:2` (u16),
`sym@6:2` (u16, `0xFF00` sentinel in leaf slots),
`par@8:4`, `lt@12:4` ('0'/marker-0x4000 child),
`rt@16:4` ('1'/marker-0x8000 child), `mark@20:2`.

`next` starts at `a5+26` and bumps by 22.

## Unpack workmem — `AllocMem(0x1004 + inlen)`, body = alloc+4

| off (body) | size      | use                                      |
|------------|-----------|------------------------------------------|
| +0         | inlen     | descrambled payload copy (pw streams)    |
| +0..2047   | ~2048     | trie nodes: `{u16 child0@0, child1@2}`,  |
|            |           | word offsets from body; leaf = long      |
|            |           | `0xFFFFFF00|sym` (negative = leaf)       |
| +2048      | 2048      | 10-bit fast table, 1024 x u16; positive  |
|            |           | = `{shift,sym}` bytes, negative =        |
|            |           | `nodeoff-0x800` deep pointer             |

Trie and descramble buffer overlap harmlessly (descramble runs
first, then the trie overwrites it).

## XpkSubParams (`a0`)

See `functions/vectors.md` — fields used: InBuf, InLen, OutBuf,
OutLen, Password, Sub[0].

## Stream format

```
+0  u16  flag word = 0
+2  u32  0xABADCAFE (no password) or pwhash(password)
+6  256-entry code table, per symbol 0..255:
       len==0 -> byte 0xFF
       else   -> byte len-1, then ceil(len/8) code bytes
                 (code left-justified, top byte first)
..  Huffman bitstream MSB-first, one code per input symbol,
    raw byte order (no delta coding — unlike xpkSMPL);
    len>16 emitted as (len-16) hi bits + 16 lo bits.
```

## XpkInfo descriptor (hunk+0x5B0)

`{1,1, 2,0}` — subinfo v1, lib v1, master v2, modes v0.
name "Huffman", long "Huffman V1.0", desc "Dynamic Huffman
Statistic Compression", id `'HUFF'`, flags `0x2009`
(0x2000 = password support), MaxPkInChunk 0xFFFE,
MinPkInChunk 0, DefPkInChunk 0xFFFE, msgs "Coding"/"Decoding"/
"Coded"/"Decoded", DefMode 100, one mode "dynamic"
{Upto 100, Flags 1, PackMem 0x3208, UnpackMem 0x1004,
PackSpeed 103, UnpackSpeed 191, Ratio 241}.
Trailing byte `0x21` ('!') after the mode name.
