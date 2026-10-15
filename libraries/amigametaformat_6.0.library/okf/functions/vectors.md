---
type: Functions
title: amigametaformat 6.0 vector map
---

# Vector map (functab h0+0xc2e, 7 absolute longs)

| LVO | target | role |
|-----|--------|------|
| -6  | 0x06e  | Open (returns 0 when drivers unavailable) |
| -12 | 0x0b8  | Close (closes 3 libs + freemem 0x5dc) |
| -18 | 0x0ec  | Expunge |
| -24 | 0x12c  | reserved |
| -30 | 0xc74  | user fn (returns 0x94 under stubs) |
| -36 | 0xc8c  | user fn |
| -42 | 0xca2  | user fn |

initfn (h0+0x44e) opens dos/intuition/graphics; InitStruct
datatab@+0x2e (byte-command format: LN_TYPE=9, LN_NAME,
lib version fields).  datasize 0x430 — large private data.
