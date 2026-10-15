---
type: Functions
title: asyncio.library 39.1 vector map
---

# Vector map (functab h0+0x04, 17 absolute longs + ffffffff)

| LVO | target | observed behavior (oracle, stubbed dos) |
|-----|--------|---------------------------------------|
| -6   | 0x17c | Open — bump opencnt, return a6 |
| -12  | 0x18a | Close — decrement; on 0+DELEXP fall into expunge |
| -18  | 0x1a8 | Expunge — Remove, close dos/utility bases, FreeMem, return seglist |
| -24  | 0x000 | reserved — hunk0+0 `moveq #0; rts` stub |
| -30  | 0x25c | calls dos -30 (Open) with filename/mode |
| -36  | 0x4a4 | returns 0 (no exec/dos call observed) |
| -42  | 0x1e0 | dos -462 (Close) + exec -690 (ReplyMsg-family) |
| -48  | 0x766 | dos -462, dos -66 (Read), dos -462 |
| -54  | 0x51c | exec -624 (GetMsg-family) + dos -462 |
| -60  | 0xa70 | returns arg-derived value |
| -66  | 0x5e8 | exec -624 + dos -462; returned -1 in oracle |
| -72  | 0xb18 | returns 1 |
| -78  | 0x628 | exec -624 + dos -462 |
| -84  | 0xb4c | returns 0 |
| -90  | 0xc0a | exec -624 + dos -462 |
| -96  | 0xb64 | exec -624 + dos -462 |
| -102 | 0x4bc | exec -624 + dos -462 |

The vectors below -24 are the asyncio async-I/O request API
(Open/Seek/Read/Write/Close/Abort/Examine-style calls), each
wrapping a dos.library operation around a shared message-port
machinery.
