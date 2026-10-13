# iff.library 16.4 — structures

## Hunk map (original, single CODE hunk)

| Offset | Content                                    |
|--------|--------------------------------------------|
| +0x00  | bootstrap/CLI entry (OldOpenLibrary dos,    |
|        | Output, Write id, CloseLibrary, d0=5, rts) |
| +0x08  | `'CHW!'` signature + `bra` to bootstrap end|
| +0x0c  | RomTag: AUTOINIT, v16, NT_LIBRARY, pri 1   |
| +0x20  | "iff.library" / id / "dos.library" strings |
| +0x94  | InitTable (dataSize=58)                    |
| +0xa4  | functab — 15 offsets (-6..-90)             |
| +0xe4  | datatab (extended InitStruct opcodes)      |
| +0x110 | initfn (InitLibData, open DOSBase, return) |
| +0x13e | LibOpen / +0x15c Close / +0x17a Expunge    |
| +0x1b8 | reserved null stub                         |
| +0x200 | NewOpenIFF / +0x206 OpenIFF entry          |
| +0x21e | FindChunk  / +0x246 GetBMHD                |
| +0x250 | GetColorTab / +0x2a4 DecodePic             |
| +0x44e | raw decoder mid-loop entry; ByteRun1 decode|
| +0x592 | SaveBitMap entry / +0x596 SaveClip entry   |
| +0x654 | save_raw / +0x672 save_crunch / +0x76a enc |
| +0x7dc | findnode / +0x7fc clrerr / +0x808 seterr   |
| +0x822 | IFFError   / +0x830 GetViewModes           |
| +0x868 | CalcViewModes helper                       |
| ~+0x8ac| hunk end                                   |

## Library private data (dataSize=58, lib base +34)

| Off | Field                                       |
|-----|---------------------------------------------|
| +34 | segment list (seglist, returned by Expunge) |
| +38 | private flags word — bit3 = delayed expunge |
| +40 | DOSBase                                     |
| +44 | head of per-task open-node list             |
| +48 | (tail/pad — 58-byte allocation)             |

Note: lib+38 is **private data**, not `lib_Flags` (offset 14).
The standard LIBF_DELEXP (bit 2 of byte 15) is unused; the
library implements its own delayed-expunge bit.

## Per-task open node (22 bytes, AllocMem)

| Off | Field                         |
|-----|-------------------------------|
|  0  | LN succ/pred (8 bytes)        |
|  8  | type/pri/name pad             |
| 14  | task APTR (FindTask(0))       |
| 18  | LONG error (IFFError channel) |

## IFF handle

OpenIFF returns `APTR` = `alloc+4`; `*(handle-4)` = total
alloc size (CloseIFF `FreeMem(h-4, *h)`).  `handle[0]` =
'FORM', `[4]` = formsize (big-endian), `[8]` = subtype,
`[12]` = first chunk.

## BMHD (20 bytes, chunk body)

w,h (u16), left,top (i16), depth,masking,compression,pad1
(u8), transparent (u16), xAspect,yAspect (u8), pageWidth,
pageHeight (i16).  DecodePic uses only w/h? — uses depth,
masking, compression; width/height for row loop count.

## DecodePic BitMap expectation

Standard graphics `struct BitMap`: BytesPerRow@0, Rows@2,
Depth@5, Planes@8.  Requires bm_Depth >= nPlanes; uses
bm_Planes[0..nPlanes-1], each row bm_BytesPerRow bytes.
