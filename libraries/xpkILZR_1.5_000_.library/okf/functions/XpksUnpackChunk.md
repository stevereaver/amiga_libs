---
type: Function
title: XpksUnpackChunk (LVO -54)
---

# XpksUnpackChunk — decoder

```
rem = *in.w++                       -> declared outlen
if rem > xsp_OutLen: return -14     (caller must preset)
w=out; width=8; wcap=256; acc=0; nb=0
while rem>0:
  refill acc to >=9 bits
  peek 9 bits
  if bit8: emit literal byte; rem--; continue
  consume flag+8; while w-outbase > wcap: width++
  read width-4 more bits -> pos:width | len-3:4
  rem -= len; copy len bytes from outbase+pos
return 0
```

`pos` is ABSOLUTE (copy source `out[pos]`).  The reservoir
refills byte-wise into `acc`; consumed bits are masked off
the top so the window stays LSB-justified.

No bound check on the copy — a terminal match longer than
the remaining count writes past outlen.  Never stores
xsp_OutLen (the caller reads the written byte count from
its own bookkeeping).  Returns only 0 or -14.
