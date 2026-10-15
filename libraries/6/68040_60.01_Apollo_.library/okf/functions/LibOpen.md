---
type: Function
title: LibOpen
description: OpenCnt++, returns the library base itself.
lvo: -6
registers: a6 = library base (in), d0 = base (out)
---

# `struct Library *LibOpen(void)`

**LVO -6**

```
addq.w #1,(32,a6)   ; lib_OpenCnt++
move.l a6,d0
rts
```

Returns its own base. Callers that then jump to user LVOs (< -24)
will crash — there are none. The stub only exists so that
`OpenLibrary("68040.library")` succeeds; any real work is delegated
by name to the pre-opened library.
