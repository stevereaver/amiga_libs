---
type: Function
title: LibOpen
description: Standard library open — bump open count, clear LIBF_DELEXP.
lvo: -6
registers: a6 base -> d0 base
---

# ``struct Library *LibOpen(void)``

**LVO -6**

```asm
addq.w  #1, lib_OpenCnt(a6)
bclr    #3, lib_Flags(a6)       ; LIBF_DELEXP
move.l  a6, d0
rts
```
