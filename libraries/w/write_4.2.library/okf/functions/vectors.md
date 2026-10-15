# write.library 4.2 — vector map

Function table (hunk1+0) is 8 absolute-long entries, `-1` terminated.
All entries relocate against hunk0.

| LVO | h0 off | name (inferred) | notes |
|-----|--------|-----------------|-------|
| -6  | 0x0d0 | Open | bumps opencnt, AllocMems 224B client ctx, copies template, runs open hooks (rexxsyslib+dos.library opens), FindPort("WRITE") retries |
| -12 | 0x1fe | Close | decrements opencnt, teardown; if last + DELEXP → Remove+FreeMem, returns seglist |
| -18 | 0x268 | Expunge | opencnt? set DELEXP, return 0 : Remove+FreeMem, return seglist |
| -24 | 0x000 | null | the DOS stub (`moveq #0,d0;rts`) doubles as reserved vector |
| -30 | 0x2d8 | ? | scans for WRITE task/port |
| -36 | 0x356 | ? | message/write op (FindPort WRITE, msg build) |
| -42 | 0x4c4 | Write/putmsg | Forbid, FindPort(a1), build msg via a2 text, PutMsg→WaitPort→GetMsg(a3) loop, Permit |
| -48 | 0x59c | teardown | frees client ctx resources (rexx close, FreeMem) |

Internal helpers:
- 0x5e0 `_listwalk` — walks ptr list at a4@(52), jsr each entry
- 0x618 `_hook1` — `if (tmpl+0x1c) (*(tmpl+0x18))(lib, &tmpl+0x1c)` → openrexx
- 0x64c `_hook2` — same for tmpl+0x28 → closedos
- 0x67c stub `moveq #0,d0;rts`
- 0x680 `_strcat`/bounded copy helper
- 0x6a4 `_errmsg` — opens dos.library, writes "Can't open version %ld of <name>" to the console/OUTPUT, closes
- 0x7a8 `_openrexx` — OldOpenLibrary("rexxsyslib.library")
- 0x7ea `_closerexx`
- 0x80c `_opendos` — OldOpenLibrary("dos.library")
- 0x846 `_closedos`

Exec LVOs used: -132 Forbid, -138 Permit, -198 AllocMem, -210 FreeMem,
-252 Remove, -294 FindTask, -324 Signal, -366 PutMsg, -372 GetMsg,
-384 WaitPort, -390 FindPort, -414 CloseLibrary, -522 -, -552
OldOpenLibrary, -636 CacheClearU.
Dos LVOs (via stored base): -30 Open, -36 Close, -48 Write, -60, -66 Seek,
-84, -90, -882, -906.
