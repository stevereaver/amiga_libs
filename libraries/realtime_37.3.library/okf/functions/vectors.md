---
file: vectors
---
# Vectors — absolute-long functab @h0+0x7c, 14 entries + -1

All 14 entries populated; each slot is itself a RELOC32->h0 site
(stored as hunk-relative offsets in the file).  Matches the
realtime_lib.i numbering exactly — the final WB3.x library has 5
more slots (-90..-114: SetSongAttrsA/GetSongAttrsA/SetPlayerHook/
GetPlayerAttrsA-position shifts etc.).

| LVO | target | symbol |
|-----|--------|--------|
| -6  | +0xde  | Open — opencnt++, clears LIBF_DELEXP |
| -12 | +0xec  | Close — opencnt--, branches to Expunge if DELEXP |
| -18 | +0xfc  | Expunge — unlink node, _CleanUpC (CloseLibrary x2), FreeMem |
| -24 | +0x14a | reserved (`moveq #0,d0 / rts`) |
| -30 | +0x5cc | _LIBLockRealTime — ObtainSemaphore on lib+0x72+n*46, lock bitmask +0xae |
| -36 | +0x622 | _LIBUnlockRealTime — releases the semaphore passed in A0 |
| -42 | +0x96c | _LIBCreatePlayerA — AllocMem 54B, calls own -54 vector |
| -48 | +0xb34 | _LIBDeletePlayer — -54 to clear attrs, flush_conductor, FreeMem |
| -54 | +0x674 | _LIBSetPlayerAttrsA — tag walk (_next_tag), may _OpenTimer |
| -60 | +0xbec | _LIBSetConductorState — state dispatch table @+0xc50 |
| -66 | +0xbac | _LIBExternalSync |
| -72 | +0xb64 | _LIBNextConductor |
| -78 | +0xb8a | _LIBFindConductor — FindName(-276) on conductor list lib+0xa0 |
| -84 | +0x9d6 | _LIBGetPlayerAttrsA |

## external calls used

exec: OpenResource -498, OpenLibrary -552, CloseLibrary -414,
InitSemaphore -558, ObtainSemaphore -564, ReleaseSemaphore -570,
AllocMem -198, FreeMem -210, AddHead -240, Remove -252,
Enqueue -270, FindName -276, Cause -180 (_CIAHandler),
Signal -324 (_TickHandler).

utility.library (v33 opened at init; only used if base nonzero):
NextTagItem -48, FindTagItem -30, GetTagData -36 — with internal
fallbacks _next_tag/_find_tag/_get_tagdata when UtilityBase is 0.

ciaa.resource/ciab.resource (OpenResource at _OpenTimer time,
CIA hw addrs 0xbfe001/0xbfd000): AddICRVector -6 / RemICRVector -12
via thunks _AddICRVector/+0x1168, _RemICRVector/+0x117c; timer
latch regs written directly (TALO/TAHI or TBLO/TBHI, CRA/CRB).

misc.resource / dos.library v33: opened at init, bases parked in
globals + lib private fields; graphics.library opened on demand by
_EClockFreq only when exec <36 (else reads SysBase+0x238).
