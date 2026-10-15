---
type: Function
title: LibNull
description: Reserved vector + unimplemented sublib slots all return 0.
lvo: -24
timestamp: 2026-10-10T09:20:00Z
---

# Signature

```c
LONG LibNull(void);  /* -> d0 */
```

# Semantics

Returns 0. In the original there is no separate stub function: the
word-offset function table encodes offset 0xff6e (-0x92), i.e. the
`moveq #0,d0 / rts` hunk entry at .text+0x00 itself, for LVO -24 and
the unused sublib slots -42 (XpksPackFree), -48 (XpksPackReset) and
-60 (XpksUnpackFree). The rebuild uses a distinct `_LibNull` symbol
with identical semantics.
