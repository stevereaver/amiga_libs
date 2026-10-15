# Vectors (10, absolute long, LVO -6..-60)

functab @h0+0x5a → targets into h0:

| LVO | target | Notes |
|-----|--------|-------|
| -6  | +0x37a | Open: `addq.w #1,lib+0x20` opencnt++, `andi.b #-9,lib+0xe` clears bit3; ObtainSemaphore(lib+0x38); then MakeLibrary(self functab) for the child lib; -> 0 under stubs |
| -12 | +0x502 | Close: semaphore-guarded; FindTask self; decrements opencnt (underflows, see defects) |
| -18 | +0x60a | Expunge: if opencnt!=0 or caller!=seglist owner → set flag bit, ret 0 (deferred); else real expunge path ->0x2b8 |
| -24 | +0x63c | reserved stub: `clr.l d0; rts` -> 0 |
| -30 | +0x1468 | sublib query: bsr +0x710; stores d0/d1 -> h1+0x14/+0x18 then `moveq #38,d1/cmp.l/sge/extb/neg` -> d0 in {0,-1} → 0 under stubs (5.17 used #36, 5.7 #32) |
| -36 | +0xa7c | dispatcher (OpenAmiSSL-family): lock via ObtainSemaphore(h1+0x5c sem); -> 0x80 error under stubs |
| -42 | +0xfce | dispatcher variant; -> 0x80 |
| -48 | +0x1090 | dispatcher variant; checks `cmpl #1,h1+0x14` init flag; -> 0x80 |
| -54 | +0x148c | dispatcher variant, forwards via +0x844; -> 0x80 |
| -60 | +0x1538 | versioned init (InitAmiSSL-family): loads d0=0x8000000c error const; -> 0x8000000c |

Under no-sublib environment the dispatchers return deterministic
error codes (0x80 / 0x8000000c); initfn->h0+0xf0 returns 0 (fail)
after writing the lib header (type 9, flags 6, ver 5 rev 19, name/id).
Exec deps observed: ObtainSemaphore/ReleaseSemaphore/FindTask/FreeMem
(+ MakeLibrary LVO -84 inside Open).
