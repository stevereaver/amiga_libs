---
type: Function
title: XpksUnpackChunk (LVO -54)
---

# XpksUnpackChunk — RLE decoder

```
loop:
  c = signed byte *in++
  if c==0: return 0
  if c>0:  copy c bytes in->out
  else:    replicate next byte -c times
```

No output bound check — negative counts replicate blindly,
literal counts copy blindly; an overrun writes past the
output buffer.  xsp_OutLen is never written (the caller
tracks the produced count itself).
