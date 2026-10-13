---
type: Structure
title: layouts
---

# xpkSQSH 1.2 (000) — layouts

The stream format, token grammar, workmem layout, XpkSubParams usage
and descriptor shape are **identical** to the 020 twin — see
[`../../xpkSQSH_1.2_020_.library/okf/structures/layout.md`](../../xpkSQSH_1.2_020_.library/okf/structures/layout.md).
Summary reproduced for standalone reading:

## Stream format

```
u16 inLen (big-endian) | u8 in[0] (first sample, raw) | bitstream
```

MSB-first bit order. `litpress` (cap 31) selects normal vs inverted
literal/match marker sense; literals are signed deltas from the
previous byte at adaptive widths 2..8 via `deltok`/`widtab`; matches
use the lentab length tree plus a 3-class distance field
(`00`+8b, `01`+14b, `1`+12b). Output budget equals inlen — the packer
can never expand data.

## Pack workmem (alloc 0x22080)

| off | content |
|-----|---------|
| +0x0000 | u16 head[0x1000] — hash-chain heads, hash = (b0<<4)^b1 |
| +0x2080 | u16 node[0x8000][2] — dual-slot chain links per position |

Dual-slot detail (verified against the 000 binary): after the
candidate compare (`cmpm.b`, up to 46 bytes), the slot written/read
is `node[d2*2 + ((char)ca[-1] < (char)cb[-1])]` — i.e. slot 1 iff the
scan byte at the mismatch position is signed-greater than the
candidate's. This is set by the `dbne` exit flags feeding `bles`,
not by the remaining match length — an easy detail to get wrong.

## XpkSubParams (as used)

| off | field |
|-----|-------|
| +0  | xsp_InBuf |
| +4  | xsp_InLen |
| +8  | xsp_OutBuf |
| +16 | xsp_OutLen (written by pack) |
| +52 | xsp_Sub[0] — workmem pointer (NULL -> pack allocs it) |

## Descriptor (verified byte-exact vs original)

Same xpkinfo/desc/msg layout as the 020 build; differences:
longname "Squash V1.2" (020: "Squash 020+ V1.2"), mode "normal" has
PackSpeed 0x0c and UnpackSpeed 0x3c (020: 0x0f/0xe9). PackMem
0x2080 in the mode block vs 0x22080 actually allocated — same
discrepancy as the 020.
