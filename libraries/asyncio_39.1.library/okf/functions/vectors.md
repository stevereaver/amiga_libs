# asyncio.library 39.1 — vector map

Functab at h0+4 (17 absolute-long entries + `0xffffffff` terminator) —
it sits *before* the RomTag (h0+0x8c): InitTable is a 4-long record
at h0+0x4c (dsize=0x22, functab→h0+4, datatab=0, initfn→h0+0x106).
lib_NegSize = 17*6 = 102.

| LVO  | h0 off | name | behaviour |
|------|--------|------|-----------|
| -6   | 0x17c  | Open    | std open, opencnt++ |
| -12  | 0x18a  | Close   | opencnt--, deferred-expunge aware |
| -18  | 0x1a8  | Expunge | Remove + FreeMem, returns seglist |
| -24  | 0x000  | —       | null stub (`moveq #0,d0;rts`) |
| -30  | 0x25c  | OpenAsync        | (a0=name,d0=mode,d1=bufsize): mode→dos Open via 3-word table h0+0x2ae {1005,1006,1004}, then shared worker h0+0x2b4 |
| -36  | 0x4a4  | OpenAsyncFromFH  | (a0=fhBPTR,d0=mode,d1=bufsize): same worker, ownsFH=FALSE — **does NOT load a4** (see defects) |
| -42  | 0x1e0  | CloseAsync | WaitPacket, flush write buf via dos Write, close fh if owned, FreeVec |
| -48  | 0x766  | SeekAsync  | (a0=file,d0=pos,d1=mode 0=CURRENT/-1=BEG/else END): buffered reposition, block-aligned refill, or V39 beyond-EOF syncfail path |
| -54  | 0x51c  | ReadAsync  | (a0=file,a1=buf,d0=len): double-buffered prefetch, crosses buffers + EOF |
| -60  | 0xa70  | WriteAsync | (a0=file,a1=buf,d0=len): buffered write-behind; NIL: (af_Handler==0) pretends success |
| -66  | 0x5e8  | ReadCharAsync  | read 1 byte via buffer or inner ReadAsync |
| -72  | 0xb18  | WriteCharAsync | write 1 byte via buffer or inner WriteAsync |
| -78  | 0x628  | ReadLineAsync  | FGetsLenAsync then drains input to next LF (truncated lines lose the tail) |
| -84  | 0xb4c  | WriteLineAsync | strlen(a1) then tail-calls WriteAsync — NO newline appended |
| -90  | 0xc0a  | FGetsAsync     | FGetsLenAsync wrapper, drops the out-length (stack long) |
| -96  | 0xb64  | FGetsLenAsync  | (a0=file,a1=buf,d0=size,a2=outlen): copies max size-1 chars stopping after LF, NUL-terminates, stores count |
| -102 | 0x4bc  | PeekAsync      | (a0=file,a1=buf,d0=len): fills buf from current position WITHOUT advancing; if buffer empty does ReadAsync(1) then un-gets |

Internal helpers (not vectors): `_freelib` h0+0xc2, open worker
h0+0x2b4, `GetFileSize` (ExamineFH→fib_Size) h0+0x724,
`RecordSyncFailure` h0+0x6d0, `RequeuePacket` h0+0x700,
`SendPacket` h0+0x9b8, `WaitPacket` h0+0x9e8.

External LVOs used — exec: OldOpenLibrary(-552), CloseLibrary(-414),
FreeMem(-210), Remove(-252), AddHead(-240), FindTask(-294),
PutMsg(-366), WaitPort(-384), CopyMem(-624), AllocVec(-684),
FreeVec(-690).  dos: Open(-30), Close(-36), Write(-48), Seek(-66),
UnLock(-90), Info(-114), IoErr(-132), DupLockFromFH(-372),
ParentOfFH(-384), ExamineFH(-390), SetIoErr(-462), ErrorReport(-480).
utility: SMult32(-138), UMult32(-144), SDivMod32(-150),
UDivMod32(-156).
