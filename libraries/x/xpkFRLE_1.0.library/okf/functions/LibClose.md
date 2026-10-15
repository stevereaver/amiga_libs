---
type: Function
title: LibClose
description: Standard close — expunges when the last user closes a deferred library.
lvo: -12
registers: a6 base -> d0 0 or seglist
---

# ``LONG LibClose(void)``

**LVO -12**

Decrements `lib_OpenCnt`; when it reaches zero and `LIBF_DELEXP`
is set, falls through to LibExpunge and returns the seglist,
else returns 0.
