# cddb.library 44.999 — vector map

RomTag @ h0+4, AUTOINIT (flags 0x80), ver 44 rev 999, NT_LIBRARY pri 0.
rt_Init -> h1+4 (InitTable: dsize=0x9c, functab->h0+0x868, datatab=0,
initfn->h0+0x20). 8 vectors (-6 .. -48):

| LVO  | off   | role |
|------|-------|------|
| -6   | 0xc4  | Open (opencnt@+32, bclr DELEXP@+14) |
| -12  | 0xd6  | Close (deferred expunge via bit3@+14) |
| -18  | 0x100 | Expunge (closelibs, Remove -252, FreeMem -210) |
| -24  | 0x00  | DOS-stub `moveq #0,d0; rts` (relocated 0 -> h0+0) |
| -30  | 0x378 | query(tags,cdinfo): ut GetTagData x7 -> fd -48 alloc -> discid -> fd -126 query -> fd -96 fetch -> strncpy fields -> fd -72 -> fd -60 free |
| -36  | 0x5fc | stub: always returns 0 |
| -42  | 0x6ae | compute CDDB discid of cdinfo (a0), store at a0+408 |
| -48  | 0x6cc | error lookup: d0 err code 0..10 -> ctx+0x1c string table, else "Unknown error"; freedb -36 can override |

Internal helpers:
- 0x158 `_openlibs` — a6=lib; OldOpenLibrary(-552) utility v36 ->
  ctx+24, freedb v2 -> ctx+20, execbase -> ctx+104. Returns 0 ok / 1 fail.
- 0x1e4 `_closelibs` — CloseLibrary(-414) both.
- 0x214 `_tagquery` — freedb -36 then utility -102 tag set on a0+16.
- 0x27c `_strncpy` — dst a5 <- src a1, cap d0 (overlap-loop idiom).
- 0x2be `_discid` — fills a3 track table + fields from cdinfo (a2):
  leadout frames a2+404 -> secs/rem via _divmod; per-track
  min*60*75+sec*75+frame-150 into a3+44, +62 stride.
- 0x618 `_dsum` — digit sum via _divmod %10.
- 0x64c `_cddbid` — classic CDDB id: sum of digit-sums(track secs)
  mod 255 <<16 | (leadout frames>>8)?? -> (leadout<<8) | ntracks.
- 0x8b0 `_runlist` — ctx fn-list iterator: cursor ctx+0x5c,
  flag ctx+0x64; pre-increments, calls each entry till 0.
- 0x8e8 `_sdiv` — signed divide wrapper.
- 0x91a `_divmod` — 32/32 -> d0 quot, d1 rem (normalize+divuw).

External LVOs: exec -552 OldOpenLibrary, -414 CloseLibrary, -252 Remove,
-210 FreeMem; utility -36 (GetTagData-like: d0=tag,d1=def,a0=list),
-102 (SetTagData-like); freedb -36,-48,-60,-72,-96,-114,-126.
freedb tags pushed in -30 are 0xfec9xxxx family (vendor base).
