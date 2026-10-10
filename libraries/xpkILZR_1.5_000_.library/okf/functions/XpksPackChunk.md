---
type: Function
title: XpksPackChunk (LVO -36)
---

# XpksPackChunk — encoder

```
if !xsp_Sub[0]: AllocMem(0x18004) -> size-prefixed block (-7 on fail)
XpksPackReset()                       -> clears head[]
head = sub[0]; chain = head+0x8000
out.w = inlen                         -> 16-bit header
a2 = in-1; rem = inlen; hash = (in[0]<<5^in[1])&0x7fff; plen=1
loop:
  if rem<3: a2+=plen; emit literal; rem--; continue
  insert plen positions (a2++, hash update, chain/head)
  pos = a2-in; walk chain[pos] candidates (precheck + 18-cap)
  best>=3 -> emit match(pos-of-best, best) at width w
  else    -> emit literal at a2
  rem -= plen; if rem<=0: break
flush residue; xsp_OutLen = w-out; return 0
```

Returns 0 on success, -17 when the bit writer reaches
out+inlen (write-then-check — the byte is already stored),
-7 on AllocMem failure.

See [algorithms/HashChain](../algorithms/HashChain.md) and
[algorithms/ILZRFormat](../algorithms/ILZRFormat.md).
