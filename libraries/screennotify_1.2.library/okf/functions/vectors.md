# screennotify.library 1.2 — vectors

Word-offset functab (offsets relative to functab @0x2e).

| LVO | file off | name (inferred) | args | behaviour |
|-----|----------|-----------------|------|-----------|
| -6  | 0x290 | Open      | — | opencnt++, return libbase |
| -12 | 0x298 | Close     | — | opencnt--; if 0 && LIBF_DELEXP -> Expunge |
| -18 | 0x2b2 | Expunge   | — | 4-stage verified unchain, signal worker, Remove+FreeMem |
| -24 | 0x3ba | (stub)    | — | `moveq #0,d0; rts` |
| -30 | 0x3be | AddClient1| d0=pri a0=arg a1=port | add node to list 1 (screen close) |
| -36 | 0x43c | RemClient1| a0=node | remove node from list 1 |
| -42 | 0x3d2 | AddClient2| same | add node to list 2 (pub status) |
| -48 | 0x442 | RemClient2| a0=node | remove node from list 2 |
| -54 | 0x3d8 | AddClient3| same | add node to list 3 (workbench) |
| -60 | 0x448 | RemClient3| a0=node | remove node from list 3 |

## Add client (shared helper @0x3dc)

`AttemptSemaphore(blk+14)`; on failure `WaitTOF()` via the
graphics base and retry, 10 attempts total (`moveq #9` DBF); gives
up returning NULL. On success `AllocMem(18, MEMF_PUBLIC)` ->
node `ln_Pri = pri`, `ln_Name = client port`, `Enqueue`, release,
caller stores arg at node+14. If the graphics base is NULL the
helper returns NULL immediately without retrying.

## Remove client (shared helper @0x44c)

`AttemptSemaphore(blk+14)`; on success `Remove`, release,
`FreeMem(node,18)`, return 1. On failure it does
`GetMsg(node->port)` and `ReplyMsg`s any pending message — this
unblocks a notifier currently waiting on its ack — returns 0.

## Node (18 bytes)

```
+0  ln_Succ, ln_Pred      (MinNode chain)
+8  ln_Type  (unused)
+9  ln_Pri   = client priority (Enqueue order)
+10 ln_Name  = client MsgPort
+14 arg      = client argument / screen filter
```

## Notification protocol

Each of the three 122-byte list blocks contains an embedded
`Message` (`mn_Length = 28`, body = `{type, arg}` at blk+80/84) and
an embedded `MsgPort` (blk+88, ln_Type=NT_MSGPORT, sigbit **8**
hardcoded, sigtask=self). The walker obtains the block semaphore,
then for every client node (skipped when node task == current
task, or when type==0 and node->arg != broadcast arg):
`PutMsg(client_port, msg)` then `WaitPort`+`GetMsg` on the block's
own port — fully synchronous, one client at a time.

## Event types

| type | list | trigger |
|------|------|---------|
| 0 | 1 | CloseScreen patch — arg = closing screen, filtered by node->arg |
| 2 | 2 | PubScreenStatus patch — pre-call when requested status bit0=1, arg = PubScreenNode |
| 1 | 2 | PubScreenStatus patch — post-call on bit0 transition mismatch, arg = PubScreenNode |
| 3 | 3 | CloseWorkBench patch — arg 0 pre-call, arg 1 on failed close; worker proc — arg 1 on new WB screen |

## Expunge unchain order

PSS (-552) -> CWB (-78) -> CS (-66) -> OSTL (-612), each
`SetFunction(intu, lvo, saved_old)` + verify the returned previous
== our hook. On mismatch: restore the foreign function to that
slot, then force our saved olds into the remaining slots, then
jump to the free path (see defects).
