---
type: Functions
title: Pony3D 1.0 vector map
---

# Vector map (functab h0+0x182, 8 absolute longs)

| LVO | target | role |
|-----|--------|------|
| -6  | h0+0x20c | Open |
| -12 | h0+0x21a | Close |
| -18 | h0+0x22e | Expunge |
| -24 | h0+0x274 | reserved |
| -30 | h1+0x000 | user fn 1 |
| -36 | h1+0x0e6 | user fn 2 |
| -42 | h1+0x10a | user fn 3 |
| -48 | h1+0x17e | user fn 4 |

initfn@h0+0x1c6 performs CopyMem (-132) + -138 + -96 and returns
0 (lib base tracked via AUTOINIT allocation, not the return).
User vectors live entirely in hunk1.
