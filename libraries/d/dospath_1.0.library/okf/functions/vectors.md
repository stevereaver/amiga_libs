# dospath.library 1.0 — vector map

Functab at h0+0x54, 13 absolute-long entries (relocated), `0xffffffff`
terminator at 0x88.

| LVO | code off | name (inferred) | behaviour |
|-----|----------|-----------------|-----------|
| -6  | 0x14e | Open    | clone-per-open: MakeLibrary(44B) + OpenLibrary dos/utility v37 into clone+36/40, SumLibrary(clone), master opencnt++, clone opencnt=1, clear DELEXP |
| -12 | 0x1ee | Close   | CloseLibrary clone+40,+36; FreeMem(clone); master opencnt--; if 0 && DELEXP -> Expunge |
| -18 | 0x264 | Expunge | opencnt<0 -> Remove+FreeMem, return seglist; else set DELEXP |
| -24 | 0x2a2 | —       | ret0 stub |
| -30 | 0x2a2 | —       | ret0 stub (same code) |
| -36 | 0x71c | FreePathList? | walk {next-BPTR, lock} chain: UnLock(node+4) then FreeVec(node) |
| -42 | 0x628 | CopyList? | a0=&chain-ptr: DupLock each node's +4 lock into a new {flag=0, lock} chain; links written as BPTRs (ptr>>2); a1=seed node |
| -48 | 0x59a | tag build | NextTagItem loop over a1 taglist; tag 0x80001001 -> names-array builder (0x2c4), tag 0x80001002 -> lock-array builder (0x41c); a0 = out ptr |
| -54 | 0x768 | probe locks | for each chain node: CurrentDir(node+4), Lock(a1,SHARED), UnLock, keep last a6@(4) in d6; restores CurrentDir; writes next-BPTR at *a0 |
| -60 | 0x894 | prune | unlink+UnLock+FreeVec every node whose +4 lock is not SameLock(a1); returns head |
| -66 | 0x82e | nextvol | a0 = DosList-ish: if a0+8==13 return *(vol+8)<<2 where vol=a0+172<<2; else 0 |
| -72 | 0x856 | setnext | same walk + writes a1>>2 into vol+8; returns previous vol+8<<2 |
| -78 | 0x918 | wbpath | a0=0 -> FindTask("Workbench") else a0@(14)@+16; _f82e(task) then _f628(result, a1) |

## Internal helpers (not in functab)

| off | role |
|-----|------|
| 0x08e | MakeLibrary thunk (functab at 0x54, 44B) + fills ln_Type=9, name, flags=6, ver 1, rev 0, idstr |
| 0x0dc | FreeMem(lib-lib_NegSize, NegSize+PosSize) via sysbase |
| 0x2c4 | name-array -> {flag,lock} chain: Lock(name,-2)/Examine via ADO fib; keeps entries with DirEntryType>0 |
| 0x41c | BPTR-array -> {flag,lock} chain: iterates raw a6=a6@ chain, Lock(node+10), Examine |
| 0x814 | leaf: a0+8==13 ? (a0+172)<<2 : 0 |

## External LVOs

- Exec: -84 MakeLibrary, -210 FreeMem, -252 Remove, -294 FindTask,
  -396 AddLibrary, -414 CloseLibrary, -426 SumLibrary, -552 OpenLibrary,
  -684 AllocVec, -690 FreeVec
- dos.library: -84 Lock, -90 UnLock, -96 DupLock, -102 Examine,
  -126 CurrentDir, -228 AllocDosObject, -234 FreeDosObject, -420 SameLock
- utility.library: -48 NextTagItem
