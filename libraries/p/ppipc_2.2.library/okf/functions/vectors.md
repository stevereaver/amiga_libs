# ppipc.library 2.2 — vector map

Function table (hunk2+0x2e) is 22 absolute-long entries, `-1`
terminated. Entries relocate against hunks 3/5/7/9.

| LVO | target | name (inferred) | notes |
|-----|--------|-----------------|-------|
| -6   | h3+0x046 | Open | `addqw #1,lib+0x20`; `bclr #3,lib+0xe` (DELEXP); d0=lib |
| -12  | h3+0x0bc | Close | `subqw #1,lib+0x20`; if cnt==0 && DELEXP → tail-call Expunge, else d0=0 |
| -18  | h3+0x05a | Expunge | opencnt? set DELEXP, d0=0 : else refuse if `*(portlist.head) != 0` (list nonempty → first node's ln_Succ); else a6=SysBase cell, Remove(lib), FreeMem(lib-negsize, neg+pos), d0=seglist cell |
| -24  | h3+0x0da | null | `moveq #0,d0; rts` |
| -30  | h5+0x0c6 | FindPort(a0=name) | Forbid, FindName(portlist,a0); if flags&0x9000 → usecount++ (via sigport), d0=port else 0; Permit |
| -36  | h5+0x114 | GetPort(a0=name) | Forbid, FindName; found → _sigport; else _mkport: AllocMem(50+strlen, PUBLIC|CLEAR), NewList(+0x14 msg list), ln_Type=4, mp_Flags=2, ln_Name→+0x30 strcpy, AddHead(portlist) — skipped entirely for name==0 (anonymous port, unlinked); then _sigport; Permit |
| -42  | h5+0x096 | UsePort(a0=port) | shared `_sigport` helper: usecount++; if flags&1 → Signal(sigtask, 1<<sigbit) |
| -48  | h5+0x172 | ReleasePort(a0=port) | NULL-safe; Forbid, --usecount; if 0 → Remove (only if ln_Name≠0), Permit, FreeMem(port, port+0x2a); else if flags&1 → Signal, Permit |
| -54  | h5+0x1ce | PortSignal(a0=name) | GetPort(name); Forbid; if flags&0xc000 (already signalled) → ReleasePort, d0=0; else AllocSignal(-1)→sigbit (fail → ReleasePort, d0=0); mp_Flags=0, sigtask=FindTask(0), flags=0x8000; Permit; d0=port |
| -60  | h5+0x248 | SetSigMode(a0=port) | Forbid; flags \|= 0x4000; flags &= 0x7fff (clears ready bit); mp_Flags=2; Permit |
| -66  | h5+0x27a | FreePortSignal(a0=port) | FreeSignal(sigbit), sigtask=0, flags &= 0x3f00; then ReleasePort |
| -72  | h5+0x2ac | PortFlags(a0=port,d0=flags) | old=flags; if sigtask==FindTask(0): flags=(old&0xff00)\|(d0&0xff); d0 = old flags if input bit15 set else usecount |
| -78  | h5+0x2f6 | PutMsgIfReady(a0=port,a1=msg) | if flags&0x9000 → PutMsg(port,msg), d0=1 else d0=0 |
| -84  | h5+0x32c | AllocMsg(d0=idx,d1=base,a0=port) | size=(idx-1)*16+base+46; fail if size-20 > 0xffff; msg+18=size-20, +28=idx, +14=port |
| -90  | h5+0x38c | FreeMsg(a0=msg) | FreeMem(msg, msg+18 + 20) |
| -96  | h7+0x000 | BrokerRequest(a0=name) | GetPort(name); if already ready (flags&0x9000) return it; else PortSignal(0) anon reply port, AllocMsg(1,0,reply), FindPort("PortBrokerPort"), fill msg 'IPPL'/'PORT'/port-ptr, PutMsgIfReady→WaitPort→GetMsg reply, release broker port; cleanup frees reply port + msg; return port iff flags&0x9000 at end |
| -102 | h9+0x000 | Str2ID(a0=str) | packs ≤4 chars into a long ('IPPL'→0x4950504c, ''→0) |
| -108 | h9+0x030 | FindID(a0=tbl,d0=id,a1=cursor) | scans 16-byte records at tbl+0x1e, count at tbl+0x1c(word); a1 cursor resumes after it; d0=record or 0 |
| -114…-132 | h3+0x0da | null | all four reserved vectors → `moveq #0,d0; rts` |

Internal helpers / support code:

- h0+0x20 `_newlist` — stack-arg NewList (a0=arg, 3 stores)
- h0+0x34 `_strlen`, h0+0x48 `_strcpy` — stack-arg amiga.lib routines
- h3+0xe0 `_t_newlist` — `jmp h0+0x20` trampoline (init runs in h3)
- h5+0x3ac `_t_strlen`, h5+0x3b2 `_t_newlist`, h5+0x3b8 `_t_strcpy` —
  jmp trampolines to h0 (h5 can't call h0 directly without relocs)
- h5+0x000 `_mkport` — allocates/zeroes port object (stack arg name,
  NULL → anonymous unlinked port), NewLists +0x14, links into h6 list
- h5+0x096 `_sigport` — the shared port-reference helper exposed as
  -42; also called by -30/-36 after lookup/create
- h7+0xf8…0x12e — eleven `jmp` stubs into h5 vectors + h10 wrappers
- h10+0x00 `_getmsgstub`, h10+0x14 `_waitstub` — `movea.l h1+0x32,a6`
  then tail-jump exec -372/-384 (a6-independent GetMsg/WaitPort)

Exec LVOs used: -132 Forbid, -138 Permit, -198 AllocMem, -210 FreeMem,
-240 AddHead, -252 Remove, -276 FindName, -294 FindTask, -324 Signal,
-330 AllocSignal, -336 FreeSignal, -366 PutMsg, -372 GetMsg, -384
WaitPort. No dos/other libraries.
