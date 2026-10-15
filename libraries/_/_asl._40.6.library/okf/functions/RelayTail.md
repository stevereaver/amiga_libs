---
type: Function
title: Relay tail (shared dispatcher)
description: Shared code path for all six public vectors; opens asl.library, calls the LVO, closes it.
lvo: -
registers: d1 = target LVO; d0/a0/a1 pass through to the real function
timestamp: 2026-10-10T18:00:00Z
---

# `RelayTail(void)` — code+0x122

```
save a6 (our base), d0-d1/a0-a1 (call args)
a1 = base->sh_RealName        /* "asl.library" (base+0x26) */
d0 = 36                       /* required version */
a0 = base->sh_OpenFunc        /* +0x22 — function pointer */
a6 = SysBase ($4)
jsr (a0)                      /* OpenLibrary("asl.library", 36) */
if (!d0) goto fail
a6 = d0                       /* real asl base */
restore args
jsr 0(a6,d1.w)                /* call LVO d1 on asl.library */
close:  save regs; a1 = a6; a6 = SysBase; CloseLibrary(a1);
        restore regs; a6 = saved base; rts
fail:   restore regs; d0 = 0; goto close   /* BUG: a6 is still
        SysBase -> CloseLibrary(exec.library) */
```

Two defects in the original, reproduced in `source/asl_relay.s`:

1. `base+0x22` (the OpenLibrary pointer) is never initialised by the
   library — init only writes the seglist at +0x2a and the InitStruct
   only writes +0x26.  Unless a host program pokes the address of
   exec's OpenLibrary (or an equivalent routine taking
   name=a1/version=d0) into this field, the relay `jsr (a0)` jumps to
   address 0.
2. On open failure the tail branches into the close path with
   a6 = SysBase, so `CloseLibrary` is invoked on exec.library.
