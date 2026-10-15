---
type: Functions
title: xpkNUKE 1.1 vector map
---

# Vector map (functab code+0xaa4, 10 absolute longs)

| LVO | target | role |
|-----|--------|------|
| -6  | 0x0d2  | Open |
| -12 | 0x0ee  | Close |
| -18 | 0x118  | Expunge |
| -24 | 0x000  | reserved (0 -> hunk start stub) |
| -30 | 0x17c  | XpkPackerInfo (returns lib+0xfe) |
| -36 | 0x244  | XpkPack — allocs 84B ctx + 0x20000 + 0x10000 tables per stream |
| -42 | 0x18c  | XpkPackFree — frees tables, leaves xsp+52 dangling |
| -48 | 0x308  | stub (returns 0) |
| -54 | 0x31a  | XpkUnpack — always returns 0; output len from xsp+16 |
| -60 | 0x35c  | stub (returns stale d0) |
