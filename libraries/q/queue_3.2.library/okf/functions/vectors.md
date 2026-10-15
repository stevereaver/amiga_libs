# queue.library 3.2 — vectors

Absolute-longword functab in hunk2 (+0), 13 entries + `0xffffffff`
terminator. All offsets are hunk0-relative.

| LVO | h0 off | fn        | summary |
|-----|--------|-----------|---------|
| -6  | 0x0c4  | Open      | OpenCnt++, clears DELEXP, returns lib base. |
| -12 | 0x0d6  | Close     | OpenCnt--; on 0 && DELEXP calls Expunge helper, returns seglist. |
| -18 | 0x100  | Expunge   | sets DELEXP; if open, returns 0. Else Remove + FreeMem(neg+pos), returns seglist from lib+34. |
| -24 | 0x000  | stub      | functab[3] = 0 -> relocated to the h0+0 `moveq #0,d0; rts`. |
| -30 | 0x2a2  | CreateQueue | a0=name, d0=type, d1=sigbit. Allocs 42-B client node + (first caller) a 96-B queue hdr: InitSemaphore(hdr+50), name strdup into hdr+10, hdr AddHead'd into lib namelist (ctx+78), NewList on hdr+14 (waiter list) and hdr+36 (node list). node: +8=type, +12=hdr, +16=1<<sigbit, +20=FindTask(0), +24=list (type!=1). Type-1: node+36=10, hdr+32++ , Signal(hdr's own task? actually node+20 task, node+16 mask). Dup-name: FindName hit -> hdr+28++ attach. |
| -36 | 0x45e  | DeleteQueue | a0=client node. Semaphore-guarded walk: rechain/free the node's +28 link or dec a2+24 sublist counters, kill type-6/pending nodes, then Remove+FreeMem(42) the node; when hdr+28 hits 0 also frees name + hdr (96). Type-2 nodes short-circuit: return hdr+38 pending count without teardown. |
| -42 | 0x5f2  | Enqueue    | a0=client node, a1=item node. item+16=client, +10=0, +12=0, +8=1; AddTail into hdr+14; client+38++; if hdr+32 waiters, walks hdr+36 signalling each type-1 waiter's task (a0+20) with mask (a0+16). No waiters (hdr+32==0) -> item killed instead (never queued). |
| -48 | 0x696  | KillNode   | a0=client, a1=node: _killnode under hdr semaphore. |
| -54 | 0x6d8  | Dequeue    | a0=client. Type-2 hdr: RemHead(hdr+24). Else: pop hdr+24 chain head via _bump (dec +10/inc +12, kill at limit type 6), or clear client's +28 via _rmvclear; then walks client+14 list: terminates chain nodes (succ==0) by _rechain into hdr+28, kills type-6, bumps others (+10++). Returns current node ptr. |
| -60 | 0x7e8  | FlushList  | a0=client. Rechains hdr+24 head into client+28 via _bump, walks client's list killing type-1 (signals hdr+20 task w/ hdr+16 mask), clears client+24. Returns 1 (0 if hdr+24 empty). |
| -66 | 0x898  | PurgeStale | a0=client. Walks hdr+14 chain; kills every node whose type != 10. Returns 1. |
| -72 | 0x8f4  | AllocItem  | d0=payload size. AllocMem(24, MEMF_PUBLIC|CLEAR=0x10001) + optional second AllocMem(d0,1) into item+20. Frees and fails cleanly on second alloc miss. |
| -78 | 0x95e  | FreeItem   | a0=item, d0=size. FreeMem(item+20,d0) if set, then FreeMem(item,24). |

## Internal helpers (h0)

| off | fn | summary |
|-----|----|---------|
| 0x020 | initfn | fills lib header (ln_Type 9, flags 6, ver 3, rev 2, name/idstr via relocated h2 refs), copies the 28-B h1 template to lib+48 via the overlapped `cmpiw #0x1cd9,d0`/`moveb (a1)+,(a6)+` loop, runs the h1[0]-counted pointer fixup (count 0 -> skipped), calls _initctx. |
| 0x158 | _rechain | Remove node's +28 link if set; Enqueue(node+28, hdr+14). a0=hdr,a1=client. |
| 0x1a0 | _rmvclear | Remove(node+28); node+28 = 0. |
| 0x1c8 | _killnode | node+10==0: Remove node, AddHead into parent's (node+16)+24 list, Signal(parent+20, parent+16). Else sets node type to 6 (dying). |
| 0x214 | _bump | dec node+10, inc node+12; if node+12 >= arg+32 or type==6 -> _killnode. |
| 0x24e | _initctx | ctx=lib+48: +20 = *4 (SysBase), +24 = lib, InitSemaphore(ctx+32), NewList(ctx+78). Returns 0. |
| 0x28e | _restore | dead-weight register frame (save/restore only). Called by Expunge before teardown. |
| 0x998 | _newlist | standard NewList: tail=0, head=&tail, tailpred=&head. |
