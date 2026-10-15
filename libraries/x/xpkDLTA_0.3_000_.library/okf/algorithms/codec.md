---
type: Algorithm
title: DLTA codec
description: Byte-wise delta filter ("bytemode"); 1:1 transform, no compression.
---

# DLTA — byte-delta transform

`xpkDLTA` is a *filter* packer: it transforms data in place-size (1:1)
to improve downstream Huffman/RLE-style packers; by itself it does not
compress.

## Pack (-36), this version

```
prev = 0
for i in 0 .. InLen-1:
    d      = in[i] - prev        (mod 256)
    out[i] = d
    prev   = d + prev            (== in[i])
OutLen = InLen ; return 0
```

First byte is differenced against 0, so `out[0] = in[0]` — each chunk
is self-contained; 0.3 removed the 0.2 chunk-chaining state
(`xsp_Sub[0]/[1]`) and both bounds checks.

## Unpack (-54)

```
acc = 0
for i in 0 .. InLen-1:
    acc   += in[i]               (mod 256)
    out[i] = acc
return 0                         (xsp_OutLen NOT updated — quirk)
```

## Loop mechanics

Both loops count a long register down to zero (`subq.l/bne`), so the
byte count is exact — unlike 0.2's `subq.w/bcc` loop which over-reads
and over-writes by exactly one byte.  InLen==0 wraps to ~4G
iterations: never feed it an empty chunk.
