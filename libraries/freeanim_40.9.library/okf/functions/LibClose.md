---
type: Function
title: LibClose
description: Guarded OpenCnt--; if it reaches 0 and LIBF_DELEXP set, expunges.
lvo: -12
registers: a6 = library base
timestamp: 2026-10-10T18:00:00Z
---

# `ULONG LibClose(void)`

**LVO -12** (code+0xf8) — registers `a6 = libbase`

```
d7 = 0
if (OpenCnt)  OpenCnt--;
if (!OpenCnt && (Flags & LIBF_DELEXP))  d7 = Expunge();
return d7;
```

Note the double test: even with OpenCnt already 0, a DELEXP flag
still triggers expunge — calling Close twice on an expunge-flagged
library frees it.  Result returned in d0 via d7.
