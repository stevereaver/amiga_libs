---
type: Function
title: XpksUnpackChunk
description: Byte-delta decoder.
---

# XpksUnpackChunk — LVO -54

`LONG XpksUnpackChunk(struct XpkSubParams *a0)` —
inverse of the encoder: out[0]=in[0] (fresh) or
accumulation from xsp_Sub[1] (continued), then
out[i]=out[i-1]+in[i].  Same guards and the same
empty-input defect as the packer.
