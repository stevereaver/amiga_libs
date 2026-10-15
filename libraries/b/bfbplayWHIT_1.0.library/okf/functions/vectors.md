# bfbplayWHIT.library -- functions

Register ABI: a6 = library base, session ptr in a0, scalar args in
d-regs.  All LVOs resolved (functab at code+0x10a, 14 longs).

## Lifecycle

- **LibInit** (initRoutine, code+0x166): a5=d0(base), stores
  a6->base+36 (exec), a0->base+44 (seglist), OpenLibrary
  ("dos.library",0) -> base+40; clears base+160/+164.
- **-6 LibOpen** (0x198): ++OpenCnt@32, clear flag bit3 @34, ret a6.
- **-12 LibClose** (0x1a6): --OpenCnt; if 0 && bit3 -> Expunge.
- **-18 LibExpunge** (0x1ba): open->set bit3 ret 0; else Remove(-252),
  CloseLibrary(+40), FreeMem(negsize..+possize) ret seglist.
- **-24** (0x200): ret 0.

## -30 InitModule (0x22a)

TagItem list in a0.  findtag helper (0x65a) walks TagItems.

| tag | meaning |
|-----|---------|
| 0x80000007 | session block: ti_Data nonzero = use it directly (the ptr IS the session, not a slot); zero -> AllocMem(80, MEMF_CLEAR) written back into ti_Data |
| 0x80000001 | filename -> dos Open(MODE_OLDFILE=1005); fail -> -6 |
| 0x80000002 | already-open handle (d6=ishandle; NOT closed after read) |
| 0x80000003 | in-memory image; used in place (sess+2 = ptr) |
| 0x80000008 | image length -> sess+10 (required with tag 3) |

File/handle path: Seek(h,0,OFFSET_END=1) then
Seek(h,0,OFFSET_BEGIN=-1) -> sess+10 (the second Seek's return is
the pre-END position); AllocMem(modlen+? observed +2 over the seek
return -- both binaries agree), Read(-42); short read -> -7;
owned handle closed via dos -36.

Then: sess+0=8, sess+26=0x74, cur_sess(code global)=sess,
sess+20 = whit_detect(modbuf).  ret 0.

Errors: -17 missing required tag, -8 AllocMem failed, -6 open
failed, -7 short read.  Error path frees modbuf(sess+10) + sess(80)
and closes an owned handle.

## -36 EndModule (0x3f6)

NULL sess -> ret 0.  If +56 playing: internal stop (the -48 code)
+ cia_stop + +56=0.  Frees modbuf(sess+10) if set, frees sess(80).
**Does not clear cur_sess -- dangling pointer (defect).**

## -42 PlayModule (0x44a)

ensure_resources (lazy ciaa/ciab OpenResource, +160/+164; name
patched 'a'->'b' in place) -> -13 on failure.
If running(+1): stop via modbuf+28, +1=0, +46=1.
If !playing(+56): cia_start; fail -> -13; +56=1.
jsr modbuf+0 with d0 = sess+24 (cursong); +1=1, +46=0; ret 0.

## -48 StopModule (0x4a6)

If running(+1) && !stopped(+46): jsr modbuf+28; +1=0; +46=1.
ret 0 (implicit; the code path falls through moveml+rts -- d0 is
leftover).  Also called internally (bsr) by Play/SetSubsong/End.

## -54 ContModule (0x4d4)

If !running(+1) && stopped(+46): jsr modbuf+42; +1=1; +46=0.
ret 0.  A resume, not a stop.

## -60 / -66 stubs (0x504/0x510): ret -1.

## -72 SetSubsong (0x51c)

d0 = new index (word compare).  If (SHORT)sess+20 < (SHORT)n ->
return sess+24 unchanged.  Else sess+24 = n; if running(+1):
modbuf+28 stop, jsr modbuf+0(n), +1=1, +46=0.  Returns sess+24
(zero-extended).  n=-1 is stored as 0xffff (no negative guard).

## -78 GetInfo (0x558): ret 0.

## -84 GetDesc (0x564): returns "Whittaker moduletype probably by
David Whittaker.\nNew CIA routines by K-P Koljonen, adapted by\n
Jarkko Vatjus-Anttila.\n".

## Module detector (0x5b0, returns count in d5)

1. scan1 from modbuf+28: words 0x43fa (lea d16,PC) && long@+4 ==
   0x4880c0fc && word@+10 == 0x41fa.  Loop bound is
   d0 = modbuf-28 -- a pointer used as a counter, so effectively
   scans until the signature is found anywhere ahead in RAM.
2. scan2 from the hit: 0x47fa && ((+4==0x51eb && +8==0x51eb) ||
   +8==0x33fc || +8==0x426b).
3. resolve d1 = a0 - (a1 + w(a1+2) - 10); d2 = w(a0+12).
   Sweep: entries w(a0+12+d2), d2 += 2/read (+4/step because each
   pass pre-increments), count = (w(a0+8)>>1)-1 per pass; exit on
   odd entry or d2 >= running-min(entry-d1).  d5 = completed sweep
   count -> stored as sess+20 (songsm1).

## CIA machinery

- ensure_resources (0x56c): if !base+160: OpenResource("ciaa") ->
  +160, patch name[3] 'a'->'b', OpenResource -> +164; either fail
  -> -1.  If +160 already set, skips even if +164 failed (retry
  never happens -- quirk).
- cia_start (0x67c): cia_stop first; period(+158) = 0x3781
  (~50Hz PAL); tries AddICRVector(-6) bit 0/1 on ciaa (+160, chip
  0xbfe001) then ciab (+164, chip 0xbfd000); stores chip->+168,
  res->+172, timer bit->+176; writes period lo/hi to TALO/TAHI or
  TBLO/TBHI (+0x400/+0x500 or +0x600/+0x700), CRx = 0x11.
- cia_stop (0x718): if +168: CRx=0, RemICRVector(-12), +168=0,
  +176=0.
- Interrupt chain (code+0x754): Interrupt "BFBPlay CIA timer."
  is_Data -> inner Interrupt (0x772: name NULL, is_Data =
  0xbfe001, is_Code = tick dispatch 0x208); is_Code = stub
  `jsr a6@(-180)` = exec Cause -> the inner node runs as a
  softint, which calls cur_sess->modbuf+14 when session live and
  running(+1) set.
