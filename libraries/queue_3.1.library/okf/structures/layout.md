# queue.library 3.1 — hunk & object layout

## File (2836 bytes)

```
0000 000003f3                 HUNK_HEADER
0004 00000000                 (no resident names)
0008 00000003                 tablesize = 3
000c 00000000 00000002        first=0 last=2
0014 0000026b 00000008 00000017   sizes: h0 0x9ac B, h1 0x20 B, h2 0x5c B
0020 000003e9 0000026b        hunk0 CODE record + size
0028 ...                      h0 body (file 0x28..0x9d3)
09d4 000003ec                 RELOC32
        2  -> hunk0: 0a 06
        3  -> hunk1: 86 74 1a
        4  -> hunk2: 5a 34 16 12
        0  (all groups descending offset order)
0a18 000003f2                 HUNK_END
0a1c 000003ea 00000008        hunk1 DATA record + size
0a24 ...                      h1 body (file 0xa24..0xa43)
0a44 000003ec                 RELOC32
        1  -> hunk0: 10          (initfn at template+0x10)
        1  -> hunk2: 08          (functab at template+0x08)
        0
0a64 000003f2                 HUNK_END
0a68 000003e9 00000017        hunk2 CODE record + size
0a70 ...                      h2 body (file 0xa70..0xacb)
0acc 000003ec                 RELOC32
        13 -> hunk0: 30 2c 28 ... 04 00   (descending)
        0
0b10 000003f2                 HUNK_END
```

## hunk0 map (hunk-relative)

| off | content |
|-----|---------|
| 0x000 | `moveq #0,d0;rts` — entry stub AND LVO -24 vector |
| 0x004 | RomTag: 4afc; MatchTag->0x04; EndSkip->0x1e; flags 0x80 (AUTOINIT); ver 3; type 9; pri 0; name->h2+0x38; idstr->h2+0x48; init->h1+0x04 |
| 0x01e | dead pad word 0x0000 |
| 0x020 | initfn / __UserLibInit wrapper (SAS/C template copy + fixup loop) |
| 0x0c4 | Open |
| 0x0d6 | Close |
| 0x100 | Expunge |
| 0x156 | nop pad |
| 0x158 | SetMarker |
| 0x1a0 | ClearMarker |
| 0x1c8 | RemoveAndReply |
| 0x214 | ReplyQMessage |
| 0x24e | __UserLibInit (SysBase/QueueBase/semaphore/list) |
| 0x28e | __UserLibCleanup (empty) |
| 0x2a2 | QOpen |
| 0x45e | QClose |
| 0x5f2 | QAddMsg |
| 0x696 | QRemMsg |
| 0x6d8 | QGetMsg |
| 0x7e8 | QReplyMsg |
| 0x898 | QFlush |
| 0x8f4 | QAllocMsg |
| 0x95e | QFreeMsg |
| 0x996 | nop pad |
| 0x998 | f_NewList (NewList clone) |
| 0x9aa | 2-byte zero pad -> 0x9ac |

## hunk1 DATA (template, copied to lib+48 by initfn)

| off | value | meaning |
|-----|-------|---------|
| +0x00 | 0 | template pad / copied to g+0 |
| +0x04 | 0x8c | InitTable.dataSize = 140 |
| +0x08 | ->h2+0 | InitTable.functionTable |
| +0x0c | 0 | InitTable.dataTable (none) |
| +0x10 | ->h0+0x20 | InitTable.initRoutine |
| +0x14 | 0 | copied to g+20, overwritten by SysBase |
| +0x18 | 0 | copied to g+24, overwritten by QueueBase |
| +0x1c | 0 | fixup-table count for the init rebase loop |

## hunk2 CODE (functab + strings)

| off | content |
|-----|---------|
| 0x00 | 13 .long absolute vectors -> hunk0 (c4 d6 100 0 2a2 45e 5f2 696 6d8 7e8 898 8f4 95e) |
| 0x34 | 0xffffffff terminator |
| 0x38 | "queue.library\0\0\0" (padded) |
| 0x48 | "queue.library 3.1\0" |
| 0x5a | "#$" tail bytes (0x2324) |

## Library base (dsize 0x8c = 140)

| off | field |
|-----|-------|
| 0x00 | struct Library (ln_Name@10, lib_Flags@14=6, lib_Version@20=3, lib_Revision@22=1, lib_IdString@24, lib_OpenCnt@32) |
| 0x22 | seglist |
| 0x30 | globals base g (a4 = lib+48 everywhere) |
| g+0x00 | template copy: 0, 0x8c, functab, 0, initfn, --, -- (28 B) |
| g+0x14 | SysBase (*4) — lib+0x44 |
| g+0x18 | QueueBase (self) — lib+0x48 |
| g+0x20 | QueuesSemaphore (SignalSemaphore, 34 B) — lib+0x50 |
| g+0x4e | Queues (List of QueueNode) — lib+0x7e |

## Runtime objects (from queue_library.h)

```
QueueNode (allocated 96 B):              QueueHandle (allocated 42 B):
  Node  qn_Node        @0   (name @10)     MinNode qh_MinNode   @0
  List  qn_List        @14  (14 B)         USHORT qh_Mode       @8
  ULONG qn_Refs        @28                 USHORT qh_Pad        @10
  ULONG qn_Read        @32                 QueueNode *qh_QNode  @12
  List  qn_Handles     @36  (14 B)         ULONG  qh_SigMask    @16
  Semaphore qn_Semaphore @50 (34 B)        Task  *qh_SigTask    @20
  (+84..95 pad)                            union @24:
QMessage (allocated 24 B):                   listen: qhl_Message @24,
  MinNode qm_MinNode  @0                        qhl_MinNode @28 (8 B),
  USHORT  qm_Status   @8                        qhl_Status @36,
  USHORT  qm_Refs     @10                       qhl_Pad @38
  ULONG   qm_Replies  @12                    send: qhs_ReplyList @24 (14 B),
  QHandle qm_Owner    @16                       qhs_MsgCount @38
  void   *qm_Data     @20
```

qm_Status: QMS_ACTIVE=1, QMS_INACTIVE=2 (bit1 of low byte, tested via
`btst #1,(9)`), QMS_REMOVED=6, QMS_MARKER=10.
qh_Mode: QMODE_LISTEN=1, QMODE_SEND=2.
Note the union overlay: the listener marker MinNode @28 aliases
qhs_ReplyList.lh_Tail/lh_TailPred.
