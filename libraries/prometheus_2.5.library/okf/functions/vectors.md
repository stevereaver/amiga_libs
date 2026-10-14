# prometheus.library 2.5 — vector map

Functab = whole of hunk1 (18 absolute-long entries relocated to hunk0,
`0xffffffff` terminator at +0x48). `rt_Init` calls
`MakeLibrary(functab, NULL, NULL, dsize=84, seglist=0)` so the table is
absolute.

| LVO  | h0 off | name                    | registers in -> out | behaviour |
|------|--------|-------------------------|---------------------|-----------|
| -6   | 0x5c6  | Open                    | a6=lib -> d0=lib    | lib_OpenCnt++, clear DELEXP(14 bit3) |
| -12  | 0x5d8  | Close                   | a6=lib -> d0        | lib_OpenCnt--; if was 1 and DELEXP -> Expunge, else 0 |
| -18  | 0x5fe  | Expunge                 | a6=lib -> d0=seg    | opencnt!=0 -> set DELEXP, ret 0; else Remove, DeletePool, CloseLibrary(utility,card), FreeMem(neg+pos), ret seglist |
| -24  | 0x66e  | (reserved)              | -> d0=0             | `clrl d0; rts` |
| -30  | 0x674  | FindBoardTagList        | a0=board|NULL, a1=taglist|NULL -> d0 | a0==0 -> head of card MinList else a0->succ; walks `while(node->mln_Succ)`; a1==0 -> next node unfiltered; else every caller tag must be present with equal ti_Data (missing tag does not disqualify, mismatch does) |
| -36  | 0x6e2  | GetBoardAttrsTagList    | a0=board, a1=taglist -> d0=count | for each caller tag: FindTagItem in board->pn_TagList(+12); found -> `*tag->ti_Data = found->ti_Data`, count++; missing -> `*tag->ti_Data = 0`; NULL ti_Data dest skipped (not counted); NULL board/taglist -> 0 |
| -42  | 0x748  | ReadConfigLong          | a0=board, d0=offset -> d0 | CacheClearU; idx=(off>>2)&63; `bswap32(cfg[idx])` |
| -48  | 0x76e  | ReadConfigWord          | a0=board, d0=offset -> d0 | CacheClearU; idx=((off>>1)&127)^1; `bswap16(cfg.w[idx])&0xffff` |
| -54  | 0x79a  | ReadConfigByte          | a0=board, d0=offset -> d0 | CacheClearU; `cfg.b[off&0xff ^ 3]` |
| -60  | 0x7c6  | WriteConfigLong         | a0=board, d0=offset, d1=data | idx=(off>>2)&63; `cfg.l[idx]=bswap32(data)`; CacheClearU |
| -66  | 0x7e6  | WriteConfigWord         | a0=board, d0=offset, d1=data | idx=((off>>1)&127)^1; `cfg.w[idx]=bswap16(data)`; CacheClearU |
| -72  | 0x806  | WriteConfigByte         | a0=board, d0=offset, d1=data | `cfg.b[off&0xff ^ 3]=data`; CacheClearU |
| -78  | 0x82e  | SetBoardAttrsTagList    | a0=board, a1=taglist -> d0=count | only `PRM_BoardOwner` is in the settable array; sets owner only if currently NULL (acquire) or new value is NULL (release); count of successful sets |
| -84  | 0x8ac  | AddIntServer            | a0=board, a1=is -> d0 | board==NULL -> 0; else `exec.AddIntServer(3, is)`, returns 1 (exec result ignored — always reports success) |
| -90  | 0x8ca  | RemIntServer            | a0=board, a1=is     | board && is != NULL -> `exec.RemIntServer(3, is)` |
| -96  | 0x8f6  | AllocDMABuffer          | d0=size -> d0=ptr   | lazy `OpenLibrary("Prometheus.card",7)` into lib+42; NULL card -> 0; else `card[-42](size)` |
| -102 | 0x930  | FreeDMABuffer           | a0=mem, d0=size     | same lazy open; card present -> `card[-48](mem,size)` |
| -108 | 0x96a  | GetPhysicalAddress      | d0=vaddr -> d0      | `boardaddr+0x100000 <= v <= boardaddr+0x1FFFFFFF` -> `v & 0x1FFFFFFF`, else 0 |

## Internal routines (not in the vector table)

| h0 off | name        | signature | notes |
|--------|-------------|-----------|-------|
| 0x000  | DOS stub    | —         | `moveq #-1,d0; rts` |
| 0x004  | RomTag      | —         | `4afc`, MatchTag->0x04 (self), EndSkip->0x1e, `rt_Flags=0` COLDSTART, `rt_Version=2`, `rt_Type=9`, `rt_Pri=0`, name->0x20, id->0x34, init->0x4ce |
| 0x078  | SizeToPri   | sp+4=size -> d0 | trailing-zero count (`log2` of size); `extbl d0` result; two `btst` form (first-iteration pre-test) |
| 0x094  | AddRequest  | (pb,size,type,tagitem*,cfgaddr) stack args | AllocPooled(30); node: size@14,type@18,tag@22,cfg@26,ln_Type=0xFE,ln_Pri=SizeToPri(size); Enqueue -> pb+70 |
| 0x0ee  | QueryCard   | (pb, cfg*, cdev) stack args | vendor==0xFFFF -> early out; AllocPooled(188) PCIBoard, AddTailMinList -> pb+58; cfg@8; writes Vendor/Device/Revision/Class/SubClass tags (bswap'd); probes 5 BARs + ROM BAR (write ~0, read mask, size=-mask&size-mask); AddRequest per active BAR; Owner/Slot/Function tags |
| 0x346  | WriteAddresses | (pb, cdev) | walks request list; mem cursor from `cd_BoardAddr+cd_BoardSize` downward, io cursor from `cd_BoardAddr+0xF0000` down; writes BAR = bswap32 of `(cursor|1)&(boardsize-1)` for type0 (MEM) and `(cursor)&(boardsize-1)` for type1 (IO) — i.e. window-relative offsets, MEM flagged with bit0; tag ti_Data gets the absolute cursor; aborts when mem dips below `board+0x100000` or io below `board+0x10000` |
| 0x3fe  | ScanBoard   | (pb, cdev) | NewList(pb+70); pb+54=cd_BoardAddr; for slot 0..3 x funcs (1 or 8 per headertype bit7): QueryCard, cfg->command=0x0700 (word, unswapped), cfg->latency=0; then WriteAddresses; `cd_Driver=pb`, `cd_Flags &= ~2` |
| 0x4ce  | rt_Init     | a0=seglist, a6=SysBase -> d0=lib | COLDSTART: MakeLibrary(84); ln_Type=9, name/idstr abs refs, flags=6, ver2 rev5, opencnt=1, seglist/SysBase/cardbase=0; MinList init at +58; CreatePool(CLEAR,752,752); AddLibrary; OpenLibrary utility v36 -> +38, expansion v36; loop `FindConfigDev(manuf 0xAD47, prod 1)` -> ScanBoard each; on failure path CloseLibrary(utility) etc. |

## Strings / embedded data in hunk0

| off   | content |
|-------|---------|
| 0x020 | `prometheus.library\0` (19B) + pad |
| 0x034 | `$VER: prometheus.library 2.5 (22.07.2003) (c) 2000-2003 by Matay.\n` + pads |
| 0x4ac | `utility.library\0` |
| 0x4bc | `expansion.library\0` |
| 0x826 | settable-tags array: `{0x6eda0005, 0}` |
| 0x8e6 | `Prometheus.card\0` |
| 0x92 / 0x672 | `nop` alignment pads |

## External LVO calls

| call site(s) | library | LVO  | function |
|--------------|---------|------|----------|
| init         | exec    | -84  | MakeLibrary |
| expunge      | exec    | -252 | Remove |
| expunge      | exec    | -210 | FreeMem |
| expunge      | exec    | -702 | DeletePool |
| expunge      | exec    | -414 | CloseLibrary (utility, card) |
| open/close   | —       | —    | inline only |
| querycard    | exec    | -708 | AllocPooled |
| querycard    | exec    | -636 | CacheClearU (around every cfg access) |
| querycard    | exec    | -246 | AddTail (MinList append) |
| addreq       | exec    | -708/-270 | AllocPooled / Enqueue |
| init         | exec    | -696 | CreatePool |
| init, dma    | exec    | -552 | OpenLibrary |
| init         | exec    | -396 | AddLibrary |
| init         | expansion | -72 | FindConfigDev |
| findboard    | utility | -48, -30 | NextTagItem, FindTagItem |
| getattrs     | utility | -48, -30 | NextTagItem, FindTagItem |
| setattrs     | utility | -90, -30, -48 | TagInArray, FindTagItem, NextTagItem |
| addint       | exec    | -168 | AddIntServer (intnum 3) |
| remint       | exec    | -174 | RemIntServer |
| allocdma     | card    | -42  | Prometheus.card alloc |
| freedma      | card    | -48  | Prometheus.card free |
