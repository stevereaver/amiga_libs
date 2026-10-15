---
type: Functions
title: Bootblock.library 3.1 vector map
---

# Vector map (functab h1+0x3a, 12 absolute longs)

| LVO | target | observed behavior (oracle) |
|-----|--------|----------------------------|
| -6  | h0+0xb8  | Open — opencnt++, exec -564/-570 (port ops) |
| -12 | h0+0xf2  | Close — decrement; DELEXP on 0 |
| -18 | h0+0x136 | Expunge — exec -576 + remove/free |
| -24 | h0+0x1ca | reserved stub |
| -30 | h3+0x0f0 | dos -30 (Open) + dos -132 — open device/unit path |
| -36 | h3+0x384 | returns 0x80 |
| -42 | h3+0x3cc | returns 0 |
| -48 | h3+0x476 | returns -1 |
| -54 | h3+0x49a | returns 0 |
| -60 | h3+0x4b6 | AllocMem+port+msg sequence (SendMsg path) |
| -66 | h3+0x4c8 | same machinery, cmd=3 |
| -72 | h3+0x5b6 | 1024B buffer alloc + msg send — bootblock read |

initfn (h0+0x2e): exec init call + OpenLibrary('dos.library').
hunk3 code additionally references 'expansion.library' and
'trackdisk.device' strings.
