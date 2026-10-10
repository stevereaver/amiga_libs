---
type: Function
title: XpksPackChunk (LVO -36)
---

# XpksPackChunk — RLE packer

```
cur=lit=in; out=outbuf; cap=outbuf+outbuflen
loop:
  run = in[cur]==in[cur+1]==in[cur+2]    (OOB at tail)
  n   = cur - lit
  if out+n+4 > cap: return -17
  if run || n==127 || cur==end:
      if n: *out++=n; copy n literals
      if cur==end: *out++=0; done
      lit = cur
  if run:
      rl=3; while in[cur+rl]==in[cur+rl-1] && rl<127 && cur+rl<end: rl++
      *out++=-rl; *out++=in[cur]
      lit=cur=cur+rl
  else:
      cur++
xsp_OutLen = out - outbuf; return 0
```

The run extension checks `in[cur+rl]==in[cur+rl-1]` for the
CURRENT `rl` before incrementing — a contiguous equal-byte
run, not a match against the start byte.
