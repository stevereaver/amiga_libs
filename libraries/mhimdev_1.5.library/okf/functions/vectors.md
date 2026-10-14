# mhimdev 1.5 — vectors and LVOs

## Library vectors (functab @hunk+0xfc, 14 absolute longs, `-1` terminator)

| LVO  | name          | code offset | notes |
|------|---------------|-------------|-------|
| -6   | Open          | 0x60  | clears LIBF_DELEXP (bit3 of flags@14), `opencnt++`, returns libbase |
| -12  | Close         | 0xc4  | `opencnt--`; if 0 && DELEXP → tail-calls Expunge; else 0 |
| -18  | Expunge       | 0x78  | if open → set DELEXP, ret 0; else Remove + FreeMem(lib-negsz, negsz+possz), ret seglist |
| -24  | Null          | 0x56  | `moveq #0,d0; rts` |
| -30  | AllocDriver   | 0x18a | in: a0=task, d0=sigmask → d0=handle\|0. AllocVec(348), env parse (below), two MsgPorts (port1=PA_SOFTINT), CreateIORequest(port2,86)=ioreq1, AllocMem(86)=ioreq2, OpenDevice(devname,unit,ioreq1,0), CopyMem ioreq1→ioreq2, ioreq2.cmd=9, sendcmd(ioreq1, CMD_RESET=1). Cascading cleanup on failure |
| -36  | FreeDriver    | 0x3b8 | a3=handle. Calls Stop(-66) then drains freelist (FreeMem 86 each), CloseDevice(ioreq1), FreeMem(ioreq2), DeleteIORequest, DeleteMsgPort ×2, FreeVec(handle) |
| -42  | QueueBuffer   | 0x42c | a3=handle, a0=buf, d0=len → d0=1/0. RemHead freelist → ioreq; if empty, AllocMem(86)+AddTail ×32 to grow pool; CopyMem ioreq1→node; io_Data=buf, io_Length=len, io_Command=3 (CMD_WRITE), mn_ReplyPort=port1; pending++ (@328); SendIO |
| -48  | GetDoneBuffer | 0x4e0 | a3=handle → d0=buf\|0. Disable; RemHead donelist(@284); Enable; node → AddTail freelist (recycle); returns node.io_Data (+40) |
| -54  | GetStatus     | 0x52a | a3=handle → `!handle?1 : (pending<=0 && state==0 ? 2 : state)` |
| -60  | Start         | 0x554 | a3=handle. state==3 → Pause(-72); else SendIO(ioreq2, cmd=9 preset at open), state=0 |
| -66  | Stop          | 0x58e | a3=handle. state!=1 → AbortIO+WaitIO(ioreq2). port1.mp_Flags=PA_IGNORE(2); move all donelist nodes → freelist; if pending>0 → sendcmd(ioreq1, 8=CMD_FLUSH) then GetMsg-drain → freelist; pending=0; mp_Flags=PA_SOFTINT(1); state=1 |
| -72  | Pause         | 0x63e | a3=handle. state==0 → ioreq1+56=1, state=3; state==3 → ioreq1+56=0, state=0; then sendcmd(ioreq1, 10). Other states → no-op |
| -78  | Query         | 0x6e0 | d1=code → d0: see classifier below |
| -84  | SetVolume     | 0x754 | a3=handle, d0=chan(0=vol,1=balance), d1=val (clamped ≤100). Computes {left,right,-1} word payload via 32×32 mul/div helpers; io_Data=&payload, io_Length=6; sendcmd(ioreq1, 20) |

### Query classifier (vec -78, d1 → d0)

| d1 range            | result |
|---------------------|--------|
| 0                   | 0 |
| 1..3                | 1 |
| 4..10               | 0 |
| 11,12               | 1 |
| 13..19              | 0 |
| 20,21               | 1 |
| 22..40              | 0 |
| 41                  | 1 |
| 42..999             | 0 |
| 1000                | → `"MHI driver for mpeg.device"` (hunk+0x696) |
| 1001                | → `"mhimdev.library 1.5 (04.03.2023)"` (hunk+0x6b1) |
| 1002                | → `"Michael Henke"` (hunk+0x6d2) |
| 1010                | 1 |
| anything else       | 0 |

## Local routines (not vectored)

| offset | routine |
|--------|---------|
| 0x00   | run-as-program stub: `linkw; moveq #-1,d0; unlk; rts` (returns -1) |
| 0xe6   | initfn: `seglist→lib+34, sysbase→lib+38`, returns d0=libbase |
| 0x834  | _sendcmd(sysbase, ioreq, cmd) — stack args; sets io_Command=cmd, io_Flags=0, byte@51=2; DoIO |
| 0x860  | _sofint — softint on port1 (is_Data=handle): drains port1 msgs → donelist@284, pending-- each, then Signal(handle.task@298, handle.sigmask@302) |
| 0x8a4  | _newlist — stack arg: classic NewList (head→&tail, tail=0, tailpred→&head) |
| 0x8b8  | __mulsi3 — stack args d0·d1 → d0 (32×32 via three `muluw`) |
| 0x8e0  | __udivmodsi4 — stack args → d0=quot, d1=rem; entry @0x8e6 = reg-arg form used by the signed wrapper |
| 0x938  | __divmodsi4 — signed wrapper: normalizes signs, `bsr`/`bpl` into 0x8e6 |
| 0x964  | static data: `.long 0`, `.long 1` |

## Exec calls

| LVO  | name            | sites |
|------|-----------------|-------|
| -120 | Disable         | GetDoneBuffer, Stop |
| -126 | Enable          | GetDoneBuffer, Stop |
| -198 | AllocMem        | AllocDriver(ioreq2), QueueBuffer pool |
| -210 | FreeMem         | FreeDriver, Expunge, fail paths |
| -246 | AddTail         | freelist/donelist moves |
| -252 | Remove          | Expunge |
| -258 | RemHead         | freelist/donelist pops |
| -324 | Signal          | softint (task+mask from handle) |
| -372 | GetMsg          | softint + Stop drain |
| -444 | OpenDevice      | AllocDriver |
| -450 | CloseDevice     | FreeDriver |
| -456 | DoIO            | _sendcmd |
| -462 | SendIO          | QueueBuffer, Start |
| -474 | WaitIO          | Stop |
| -480 | AbortIO         | Stop |
| -552 | OldOpenLibrary  | AllocDriver ("dos.library" v37) |
| -414 | CloseLibrary    | AllocDriver |
| -624 | CopyMem         | devname copy (255 B), ioreq copies |
| -654 | CreateIORequest | AllocDriver |
| -660 | DeleteIORequest | FreeDriver + fail paths |
| -666 | CreateMsgPort   | AllocDriver ×2 (via a2) |
| -672 | DeleteMsgPort   | FreeDriver + fail paths |
| -684 | AllocVec        | AllocDriver (handle 348 B, env buf 1024 B) |
| -690 | FreeVec         | fail paths |

## dos.library calls (via dosbase in d5)

| LVO  | name            | site |
|------|-----------------|------|
| -228 | AllocDosObject  | AllocDriver (DOS_RDARGS=5) |
| -234 | FreeDosObject   | AllocDriver |
| -798 | ReadArgs        | AllocDriver (`"DEVICE,UNIT/N"`) |
| -858 | FreeArgs        | AllocDriver |
| -906 | GetVar          | AllocDriver (`"MHIMDEV"` → `"<dev>,<unit>"`) |
