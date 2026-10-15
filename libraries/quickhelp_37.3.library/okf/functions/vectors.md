---
type: Index
title: vectors
timestamp: 2026-10-15T00:00:00Z
---

# Vector map — quickhelp.library 37.3

functab @hunk3+0 (absolute longs, `ffffffff` terminator); lib base
dataSize 0x204.

| LVO | target (hunk0) | role |
|-----:|------|------|
| -6  | 0x0d0 | Open — inc opencnt, clear DELEXP, clone data area (AllocMem 0x1c8+master@0x36+60, copy from lib-0x2a, checksum 0x10d9 verify, dep-register via sub 0x918/0x2e0), fail path frees clone + dec master cnt |
| -12 | 0x1fe | Close — dec cnt; at 0 + DELEXP -> expunge; frees clone chain |
| -18 | 0x268 | Expunge — bset DELEXP; if cnt==0: FreeMem priv + Remove + FreeMem(base, neg+pos) |
| -24 | 0x000 | stub (hunk0+0 moveq#0/rts) |
| -30 | 0x48a | main entry: split text on \n (max 10 lines, >10 -> "Too many new line chars" error), measure via intuition TextExtent, OpenWindowTagList, Move/Text per line, cleanup; error code -> a4@(4) |
| -36 | 0x8dc | cleanup: if lib+0x1f4 (window) != 0 -> CloseWindow via intu base at +0x1ec |
| -42 | 0x906 | getter: returns *(a6+0x40) |
