---
file: log
---
# Work log

- 2026-10-15: realtime 37.3 — 2-hunk AUTOINIT SAS/C build.
  CODE h0 0x4ae longs + DATA h1 declared 0x19/stored 4 longs.
  InitTable dsize 0xb0; 14-entry abs-long functab, all populated;
  HUNK_SYMBOL tables in both hunks.  Raw .byte emission +
  fixup.py splicing original header/tails: BYTE-IDENTICAL.
- machine68k oracle (work/oracle.py): init opens misc.resource /
  dos.library v33 / utility.library v33, InitSemaphore x2,
  _InitTimer; open x2; all 14 vector slots; LockRealTime(0)/
  UnlockRealTime roundtrip; CreatePlayerA+DeletePlayer; close x2
  (fires deferred expunge); expunge.  invalid accesses counted
  (414, aggregated via mem.set_invalid_func).  orig vs rebuild
  logs identical -> RUNTIME-IDENTICAL.
