# queue.library 3.1 — vector map

Functab at hunk2+0x00, 13 absolute-long entries (all relocated to
hunk0), `0xffffffff` terminator at hunk2+0x34. Names from the shipped
`queue.fd` / `queue_library.c` (##bias 30).

| LVO | hunk0 off | name | signature / behaviour |
|-----|-----------|------|------------------------|
| -6  | 0x0c4 | Open   | lib_OpenCnt++; clear LIBF_DELEXP; return lib |
| -12 | 0x0d6 | Close  | OpenCnt--; if 0 && LIBF_DELEXP -> tail-call Expunge; return its result (seglist) or 0 |
| -18 | 0x100 | Expunge| set LIBF_DELEXP; if OpenCnt==0: __UserLibCleanup (empty), Remove(lib), FreeMem(lib-posSize, pos+neg), return seglist |
| -24 | 0x000 | —      | reserved; aliases the `moveq #0,d0;rts` entry stub |
| -30 | 0x2a2 | QOpen   | `QOpen(name a0, mode d0, sigbit d1)` -> QueueHandle. AllocMem(42, PUBLIC\|CLEAR); under QueuesSemaphore, FindName(&Queues,name): miss -> AllocMem QueueNode(96), InitSemaphore+Obtain qn_Semaphore, strdup name via AllocMem(len+1,PUBLIC)+CopyMem, AddHead Queues, NewList qn_Handles/qn_List, qn_Refs=1; hit -> Obtain qn sem, qn_Refs++. AddHead qn_Handles, fill qh (mode/qn/1<<sigbit/FindTask(0)); QMODE_LISTEN(1): qn_Read++, qhl_Status=QMS_MARKER(10), Signal self; else NewList qhs_ReplyList. Release both sems, return qh; any alloc failure unwinds and returns 0 |
| -36 | 0x45e | QClose  | `QClose(qh a0)` -> ULONG. Obtain QueuesSem then qn sem (deadlock-avoid order). QMODE_SEND: if qhs_MsgCount nonzero -> release both, return count. Else: if marker linked -> ClearMarker, walk backwards via mln_Pred decrementing qm_Replies on ACTIVE/REMOVED msgs; if no marker but qhl_Message set -> refs--/replies++. Then walk qn_List forward via mln_Succ: RemoveAndReply msgs that are (ACTIVE && replies>=qn_Read) or REMOVED; stop at MARKER. qn_Read--. Remove qh from qn_Handles, FreeMem(qh,42), --qn_Refs; on last ref release qn sem, Remove qn from Queues, FreeMem name (strlen+1) and qn(96); release QueuesSem; return 0 |
| -42 | 0x5f2 | QAddMsg | `QAddMsg(qh a0, msg a1)`. Fill msg: qm_Owner=qh, qm_Refs=0, qm_Replies=0, qm_Status=QMS_ACTIVE(1). Obtain qn sem, AddTail qn_List, qhs_MsgCount++. If qn_Read: walk qn_Handles and Signal every LISTEN handle's SigTask/SigMask; else RemoveAndReply(msg) (no readers). Release sem |
| -48 | 0x696 | QRemMsg | `QRemMsg(qh a0, msg a1)`. Obtain qn sem, RemoveAndReply(msg), release |
| -54 | 0x6d8 | QGetMsg | `QGetMsg(qh a0)` -> QMessage*. Obtain qn sem. SEND mode: RemTail qhs_ReplyList, MsgCount--, release, return msg. LISTEN: if qhl_Message set -> next=mln_Succ, ReplyQMessage(auto-reply current), msg=next; elif marker linked -> ClearMarker; else msg=qn_List.lh_Head. Walk forward: if succ==NULL -> SetMarker(qh,msg->pred), return NULL; if QMS_INACTIVE bit -> if REMOVED RemoveAndReply, skip; else qm_Refs++, stop. Store qhl_Message, release, return msg |
| -60 | 0x7e8 | QReplyMsg | `QReplyMsg(qh a0)` -> ULONG. NULL qhl_Message -> return 0. Else obtain qn sem, SetMarker(qh,msg), next=mln_Succ, ReplyQMessage(qn,msg); scan forward for a QMS_ACTIVE msg -> Signal own SigTask/SigMask (reminder); qhl_Message=NULL, release, return 1 |
| -66 | 0x898 | QFlush  | `QFlush(qh a0)` -> 1. Obtain qn sem; walk qn_List: RemoveAndReply every msg except QMS_MARKER; release |
| -72 | 0x8f4 | QAllocMsg | `QAllocMsg(size d0)` -> QMessage*. AllocMem(24, PUBLIC\|CLEAR); if size: qm_Data=AllocMem(size, MEMF_SHARED_READ=0) or unwind+NULL |
| -78 | 0x95e | QFreeMsg  | `QFreeMsg(msg a0, size d0)`. FreeMem(qm_Data,size) if set; FreeMem(msg,24) |

## Internal helpers (not in functab)

| hunk0 off | name (C source) | behaviour |
|-----------|-----------------|-----------|
| 0x020 | __UserLibInit wrapper | stores seglist@lib+34, ln_Type=9, ln_Name, lib_Flags=6, ver/rev/idstr; copies 28-byte template DATA->lib+48; runs pointer-rebase fixup loop (count=DATA[7]=0); calls f_24e; returns lib if it returned 0 else 0 |
| 0x158 | SetMarker  | if qh->marker.mln_Succ: Remove(&qh->qhl_MinNode); Insert(&qn->qn_List, &qh->marker, msg-pred) |
| 0x1a0 | ClearMarker | Remove(&qh->qhl_MinNode); mln_Succ=NULL |
| 0x1c8 | RemoveAndReply | if !qm_Refs: Remove(msg), AddHead to owner qhs_ReplyList, Signal(owner SigTask,SigMask); else qm_Status=QMS_REMOVED(6) |
| 0x214 | ReplyQMessage | qm_Refs--, qm_Replies++; if replies>=qn_Read || status==REMOVED -> RemoveAndReply |
| 0x24e | __UserLibInit | SysBase=*(4)@g+20, QueueBase=lib@g+24, InitSemaphore(&QueuesSemaphore@g+32), NewList(&Queues@g+78); returns 0 |
| 0x28e | __UserLibCleanup | empty (prologue+epilogue only) |
| 0x998 | f_NewList | NewList clone: Tail=0, TailPred=&Head, Head=&Tail |

## External LVOs (all exec.library)

-198 AllocMem, -210 FreeMem, -234 Insert, -240 AddHead, -246 AddTail,
-252 Remove, -264 RemTail, -276 FindName, -294 FindTask, -324 Signal,
-558 InitSemaphore, -564 ObtainSemaphore, -570 ReleaseSemaphore,
-624 CopyMem
