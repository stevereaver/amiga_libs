---
type: Structure
title: xpkNUKE_1.9 workspace + lib base layout
timestamp: 2026-10-14T00:00:00Z
---

# Library base

Standard NT_LIBRARY base; only extension is `lib+0x38` = seglist
(stored by LibInit, used by Expunge/Close for Remove+FreeMem).

# Pack workspace — 196,700 bytes at xsp_Sub[0]

| off  | size | field | notes |
|------|------|-------|-------|
| +0   | 4    | src     | input base (a0) |
| +4   | 4    | dst     | output base |
| +8   | 4    | tab1    | -> +92: pair->pos head, 64K words |
| +12  | 4    | tab2    | -> +92+0x20000: pos->prev chain, 32K words |
| +16  | 4    | outcur  | next stream-slot write position |
| +20  | 4    | litptr  | literal write ptr (descends from dst+outmax) |
| +24  | 4    | srcend  | src + (SHORT)inlen |
| +28  | 4    | t2front | tab2 lazy-clear frontier (0x3ea) |
| +32  | 2    | inlen   | xsp_InLen low word |
| +34  | 2    | outmax  | OutBufLen-4 low word |
| +36  | 2    | lastpos | inlen - 1 |
| +38  | 2    | litstart| first pending literal index |
| +40  | 2    | litcnt  | pending literals - 1 |
| +42  | 2    | window  | 0x6a8f hash-chain window |
| +44  | 8    | ctr1-4  | bit counters for the 4 streams |
| +52  | 12   | acc1-4  | accumulators (acc3 rorl, acc4 asll\|v) |
| +64  | 16   | ptr1-4  | pending-slot writers, seeded &scratch |
| +80  | 12   | scratch | staging until first real slot |
| +92  |      | tab1    | 0x20000 bytes |
| +92+0x20000 | | tab2 | 0x10000 bytes |

# XpkSubParams fields used

`xsp_InBuf/InLen/OutBuf/OutBufLen` read; `xsp_OutLen` (xsp+16)
written by both pack and unpack; `xsp_Sub[0]` = workspace cache
(cleared by PackFree).
