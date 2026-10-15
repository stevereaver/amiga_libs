---
type: Functions
title: iconobject.library 40.8 vector map
---

# Vector map (functab h1+0x12c, 11 absolute longs -> hunk0)

| LVO | target | observed (oracle) |
|-----|--------|-------------------|
| -6  | 0x7ae | Open — opencnt++, return a6 |
| -12 | 0x7dc | Close — decrement, DELEXP on 0 |
| -18 | 0x800 | Expunge — Remove/FreeMem |
| -24 | 0x85c | reserved stub |
| -30 | 0x3be | user fn |
| -36 | 0x4ce | returns 0x80 |
| -42 | 0x4ea | returns arg-derived pointer |
| -48 | 0x582 | returns arg pointer |
| -54 | 0x5a6 | returns -1 (fails under stubs) |
| -60 | 0x624 | returns arg pointer |
| -66 | 0x608 | returns arg pointer |

initfn (h0+0x75e): exec init, opens dos/intuition/utility v39,
exec -696 msg-port alloc; on failure path Remove+FreeMem the lib
base itself (self-freeing init) then return 0.
