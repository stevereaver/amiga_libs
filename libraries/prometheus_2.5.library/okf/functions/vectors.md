# prometheus.library 2.5 — vectors

MakeLibrary-style absolute-long functab in hunk1 (DATA), 18 entries +
`0xffffffff` terminator. Offsets are hunk0-relative.

| LVO | h0 off | fn | summary |
|-----|--------|----|---------|
| -6   | 0x5c6 | Prm_Open  | OpenCnt++, clears LIBF_DELEXP, returns lib. |
| -12  | 0x5d8 | Prm_Close | OpenCnt--; on last close with DELEXP set, runs Expunge and returns its result. |
| -18  | 0x5fe | Prm_Expunge | sets DELEXP when open; else Remove, DeletePool(lib+50), CloseLibrary(utility + lazy card base), FreeMem(neg+pos), returns seglist. |
| -24  | 0x66e | ExtFunc   | `clr.l d0; rts` reserved stub. |
| -30  | 0x674 | Prm_FindBoardTagList | a0=node (NULL->pb_Cards head), a1=taglist. Walks the PCIBoard MinList; a board matches iff every non-NULL request tag is present in its pn_TagList **and** has an equal ti_Data. NULL taglist matches first board. |
| -36  | 0x6e2 | Prm_GetBoardAttrsTagList | a0=board, a1=taglist `{tag,&dest}` pairs. For each item, FindTagItem in board->pn_TagList(+12); writes the found ti_Data (or 0) through item->ti_Data. Returns count written. |
| -42  | 0x748 | Prm_ReadConfigLong | a0=board, d0=offset. `bfextu d0{24:6}` index, long from pn_ConfigBase(+8) + CacheClearU, bswap32 result. |
| -48  | 0x76e | Prm_ReadConfigWord | same with `{24:7}` + `eoriw #1` word-in-long swap, bswap16. |
| -54  | 0x79a | Prm_ReadConfigByte | `eorib #3` byte-in-word swap, single byte read. |
| -60  | 0x7c6 | Prm_WriteConfigLong | a0=board, **d0=offset, d1=data** (reversed vs the public docs — fixed only in v3.0). bswap32 store + CacheClearU. |
| -66  | 0x7e6 | Prm_WriteConfigWord | `{24:7}`+`eoriw #1`, bswap16 store + CacheClearU. |
| -72  | 0x806 | Prm_WriteConfigByte | `eorib #3` byte store + CacheClearU. |
| -78  | 0x82e | Prm_SetBoardAttrsTagList | a0=board, a1=taglist. Only `PRM_BoardOwner (0x6eda0005)` is settable (`_settable` array); copies ti_Data only when the board's existing tag is 0 or the new value is 0. Returns count changed. |
| -84  | 0x8ac | Prm_AddIntServer | a0=board, a1=interrupt. exec AddIntServer(3,intr) — Prometheus interrupt is int 3. Returns 1 (0 if board NULL). |
| -90  | 0x8ca | Prm_RemIntServer | RemIntServer(3,intr) if both args non-NULL. |
| -96  | 0x8f6 | Prm_AllocDMABuffer | d0=size. Lazy-opens `Prometheus.card` v7 into lib+42, forwards to card vector -42. |
| -102 | 0x930 | Prm_FreeDMABuffer | a0=mem, d0=size; lazy card open, forwards to card -48. |
| -108 | 0x96a | Prm_GetPhysicalAddress | d0=vaddr. Returns `vaddr & 0x1fffffff` when inside `[board+0x100000, board+0x1fffffff]`, else 0. |

## Internal routines (h0)

| off | fn | summary |
|-----|----|---------|
| 0x078 | _sizetopri | trailing-zero count of size -> ln_Pri (Enqueue priority). |
| 0x094 | _addreq | (pb,size,type,tag,cfgreg): AllocPooled 30B SpaceReq @ pb+50 pool, ln_Type=0xfe, ln_Pri=log2(size), Enqueue -> pb+0x46 requests. |
| 0x0ee | _querycard | (pb,cfg,cdev): vendor==0xffff -> skip. AllocPooled ~67B PCIBoard, AddTailMinList -> pb+0x3a cards, fills taglist (vendor/device/class/rev/...), walks 5 BARs + ROM BAR building SpaceReqs for nonzero BARs (type from bit0: mem/io), CacheClearU around probing writes. |
| 0x296 | _writeaddr | (pb,cdev): allocates BAR windows top-down — mem cursor starts at boardaddr+cd_BoardSize, io cursor at boardaddr+0xf0000; per request writes `(cursor-1..)&sizemask` bswapped into the BAR and the assigned address into sr_Tag->ti_Data; CacheClearU per write. |
| 0x3fe | _scanboard | (pb,cdev): NewList pb+0x46, pb+54=cd_BoardAddr, cfgbase=board+0xf0000; 4 slots (cfg+0x2000*slot) x 1|8 funcs (headertype bit7); per func _querycard then writes command=0x0700, latency=0 into cfg+4/+13; finally _writeaddr, sets cd_Driver=pb, clears cd_Flags bit1. |
| 0x4ce | rt_Init | (a0=seglist, a6=SysBase): MakeLibrary(h1 functab, 84B), fills header (type 9, flags 6, ver 2, rev 5, OpenCnt=1), NewList-like init of pb_Cards(+0x3a) & pb_Requests(+0x46), CreatePool(MEMF_CLEAR,752,752)->+50, AddLibrary, OpenLibrary utility 36 + expansion 36, FindConfigDev(0xad47,1) loop -> _scanboard per board; success requires utility open; result=lib or NULL. |

exec calls used: MakeLibrary -84, AddIntServer -168, RemIntServer -174,
FreeMem -210, AddTail -246 (MinList variant), Remove -252,
Enqueue -270, AddLibrary -396, CloseLibrary -414, OpenLibrary -552,
CacheClearU -636, CreatePool -696, DeletePool -702, AllocPooled -708.
expansion: FindConfigDev -72. utility: FindTagItem -30, NextTagItem -48,
TagInArray -90. Prometheus.card: -42 AllocDMABuffer, -48 FreeDMABuffer.
