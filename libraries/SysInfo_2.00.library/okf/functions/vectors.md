---
type: Functions
title: SysInfo.library 2.00 vector map
---

# Vector map (hunk2 functab, absolute longs -> hunk0)

| LVO | target | observed behavior (oracle) |
|-----|--------|----------------------------|
| -6  | 0x0c4 | Open — bump opencnt, return a6 |
| -12 | 0x0d6 | Close — decrement; DELEXP path on 0 |
| -18 | 0x100 | Expunge — Remove/FreeMem, close bases |
| -24 | 0x000 | reserved — hunk0+0 `moveq #0; rts` stub |
| -30 | 0x158 | exec -684 (AllocSignal/CreateMsgPort area) |
| -36 | 0x232 | exec -690 (ReplyMsg family) |
| -42 | 0x26e | returns 0x80 |
| -48 | 0x29a | exec -132 + exec -294 (FindPort) |
| -54 | 0x2f0 | exec -132 + exec -294 |
| -60 | 0x34c | exec -132 + exec -294 |
| -66 | 0x362 | returns -1 (port lookup fails w/ stubs) |
| -72 | 0x498 | returns -1 |
| -78 | 0x5de | exec -684 with small size arg |
| -84 | 0x6fe | exec -306/-336/-690 (semaphore + reply) |
| -90 | 0x7aa | returns 0 |
| -96 | 0x848 | exec -132 with port arg |
