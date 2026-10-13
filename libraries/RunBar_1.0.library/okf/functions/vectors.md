# RunBar 1.0 — vector table

LONG-absolute functab (12 `dc.l` entries + `dc.l -1`) in the
third hunk; InitTable in hunk1+4 `{dsize 0x194, functab, 0,
initfunc=code+0x20}`.

| LVO  | target (orig) | function                               |
|------|---------------|----------------------------------------|
| -6   | 0x0c4         | LibOpen                                |
| -12  | 0x0d6         | LibClose                               |
| -18  | 0x100         | LibExpunge                             |
| -24  | 0x000         | reserved stub (entry `moveq#0,rts`)    |
| -30  | 0x158         | RB_LockTable                           |
| -36  | 0x196         | RB_Add                                 |
| -42  | 0x2e2         | RB_Remove                              |
| -48  | 0x386         | RB_Send                                |
| -54  | 0x452         | RB_Reset                               |
| -60  | 0x492         | RB_Teardown                            |
| -66  | 0x5aa         | RB_Update                              |
| -72  | 0x614         | RB_Unlock                              |

## Entry points

- `LibInit` (code+0x20): fills lib header by hand (type 9,
  flags 6, name, ver 1, rev 0, idstr), seglist @+34; copies 32
  longs from the DATA hunk base into lib+48 (**reads 92 bytes
  past the 36-byte hunk**), then a dead fixup pass
  (count = hunk1[8] = 0), then `bsr` a `moveq#0;rts` stub —
  nonzero would fail init (never happens).  `d0=lib`.
- `LibOpen` (0xc4): `++OpenCnt`, clear DELEXP, return base.
- `LibClose` (0xd6): `d0=0; --OpenCnt`; on 0 with DELEXP set:
  `bsr` the -18 body (which re-sets DELEXP and re-tests
  OpenCnt==0 first), return its seglist.
- `LibExpunge` (0x100): `bset DELEXP`; OpenCnt!=0 -> ret 0;
  else dead `bsr` to a bare `rts` hook, seglist=d7, Remove(lib),
  `FreeMem(base-NegSize, NegSize+PosSize)` via `moveal 4,a6`,
  return seglist.

## Functions (register ABI: a6=base)

- **-30 RB_LockTable()** — `priv->flag=1`; returns `priv->ent`
  (lib+0x54).  While flag==1, RB_Remove is disabled.
- **-36 RB_Add(a0=key, a1=fc, a2=f8, a3=obj)** — lazy-init on
  magic mismatch; 0=ok, 4=key NULL, 3=dup (key match, or — when
  `obj+6 == 1` — name-string match on `obj+2` vs slot obj+2),
  2=table full, 5=port alloc fail.  Creates an **anonymous**
  MsgPort (pri 0) into `slot.port`; stores
  `{key, port, f8, fc, obj}`.
- **-42 RB_Remove(a0=key)** — `if flag==1 return 1` (stale
  d0 quirk); find slot; clear key; drain pending msgs via
  GetMsg+ReplyMsg; DeletePort.  ret 0.
- **-48 RB_Send(d0=arg, a0=key)** — find slot; create temp
  anon port; AllocMem(28, PUBLIC|CLEAR) msg
  `{type=5,len=28,reply=rp,body={0x80800000,arg}}`;
  Forbid;PutMsg(slot.port);Permit;WaitPort(rp);GetMsg(rp)
  (dead-stored); FreeMem(msg); DeletePort(rp); ret 0 —
  **silently 0 on not-found and alloc-fail too**.
- **-54 RB_Reset()** — clear 15 slot keys, set magic, clear
  flag; ret 0.  **Leaks every live port** (fields kept, key=0
  makes slot reusable; Add overwrites slot.port).
- **-60 RB_Teardown()** — per used slot: key=0; temp port;
  msg `{0x80800001,0}`; Forbid/PutMsg/Permit/WaitPort/GetMsg;
  free msg; delete temp port; drain slot.port with
  GetMsg+ReplyMsg; DeletePort(slot.port).  Then magic=0. ret 0.
- **-66 RB_Update(a0=key, a1=fc, a2=f8)** — find slot; store
  non-null f8 -> +8, fc -> +0xc; ret 0.
- **-72 RB_Unlock()** — `priv->flag=0`; ret 0.

## Exec calls used

`moveal 4:w,a6` before every call (no stored SysBase):
Forbid(-132), Permit(-138), AllocMem(-198), FreeMem(-210),
Remove(-252), FindTask(-294), AllocSignal(-330),
FreeSignal(-336), AddPort(-354), RemPort(-360), PutMsg(-366),
GetMsg(-372), ReplyMsg(-378), WaitPort(-384).
