---
type: Function
title: XpksPackChunk
description: Byte-delta encoder.
---

# XpksPackChunk — LVO -36

`LONG XpksPackChunk(struct XpkSubParams *a0)` —
size-preserving byte-delta encoder:

    fresh chunk (xsp_Sub[0]==0): out[0]=in[0],
        out[i]=in[i]-in[i-1]
    continued (xsp_Sub[0]!=0): every byte is a delta
        from xsp_Sub[1] onward (cross-chunk chaining)

The rolling value is the *reconstructed* byte
(prev += delta), which equals the previous input byte.
Final state written back to xsp_Sub[1].  Guards:
inlen > outbuflen -> -10; inlen > 0x10000 -> -11.
Empty input -> catastrophic ~64KB overrun in the
shipped code (see findings/Quirks.md).
