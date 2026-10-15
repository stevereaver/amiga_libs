---
type: Algorithm
title: DLTA codec
description: Byte-wise delta filter ("ByteMode"); 1:1 transform, no compression.
---

# DLTA — byte-delta transform

`xpkDLTA` is a *filter* packer: 1:1 transform meant to sharpen the
distribution for downstream statistical packers; by itself it does not
compress.

## Pack (-36)

```
if InLen > OutBufLen: return -10      (XPKERR_SMALLBUF)
if InLen > 0x10000:   return -11      (XPKERR_LARGEBUF)
OutLen = InLen
prev = in[0]; out[0] = prev
if xsp_Sub[0]: prev = xsp_Sub[1]      (chunk carry-in)
for i in 1 .. InLen-1:                (see off-by-one note)
    d      = in[i] - prev             (mod 256)
    out[i] = d
    prev   = d + prev                 (== in[i])
xsp_Sub[1] = prev                     (chunk carry-out)
return 0
```

## Unpack (-54)

Identical guards and carry; the inner step is the inverse:
`acc += in[i]; out[i] = acc`.

## Cross-chunk carry

When `xsp_Sub[0]` is nonzero the differencing continues from
`xsp_Sub[1]` — the last byte of the previous chunk — and the new last
byte is stored back, so a stream of chunks can chain delta state.
The longword stored keeps d0's unrelated upper bytes; only the low
byte matters.  (Removed in 0.3: every chunk is self-contained.)

## Off-by-one (verified on the shipped binary)

The loop is `subq.w #1,d1 / bcc`, a do-while that exits on borrow from
0: it executes InLen bodies after the first byte, so **InLen+1 bytes
are actually read and written** while OutLen reports InLen.  Symmetric
in pack and unpack, so round-trips still recover.  With InLen==0 the
word counter wraps to 0xffff and ~64K bytes are written — never feed
it an empty chunk.  0.3 switched to `subq.l/bne` which counts exactly
(but still runs away on 0).
