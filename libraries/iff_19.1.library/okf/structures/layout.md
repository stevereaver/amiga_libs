# iff.library 19.1 — structures

## Hunk map

File: HUNK_HEADER(0x03f3, 1 hunk, size 0x280 longs) →
HUNK_CODE at file 0x18, code body at file 0x20,
RELOC32 table, HUNK_END.  All offsets below are **code**
offsets (file − 0x20); see index.md for the full map.

## Library private data (dataSize = 60, lib base +34)

| Off | Field |
|-----|-------|
| +34 | **ExecBase** — cached at init, used for every exec call |
| +38 | DOSBase (OldOpenLibrary("dos.library") at init) |
| +42 | segment list (returned by LibExpunge) |
| +46 | MinList of per-task OpenNodes (head/tail/tailpred) |

Compare 16.4: +34 seglist, +38 private delayed-expunge flag
word, +40 DOSBase, +44 list head — 19.1 moved to the
conventional layout (ExecBase first, real lib_Flags bit3
for delayed expunge).

## Per-task open node (22 bytes, AllocMem PUBLIC|CLEAR)

| Off | Field |
|-----|-------|
|  0  | MinNode succ/pred (8 bytes) |
|  8  | type/pri/name pad (zeroed by MEMF_CLEAR) |
| 14  | task APTR — SysBase->ThisTask read at lib+34+276 |
| 18  | LONG error — the IFFError channel |

## IFF handle

`OpenIFF`/`NewOpenIFF` return `node+4`; `*(handle-4)` is
the total AllocMem size for CloseIFF's FreeMem.
`handle[0]`='FORM', `[4]`=formsize (BE), `[8]`=subtype,
`[12]`=first chunk.  Alloc = `12 + formsize` (16.4 used
`(formsize+4)&~3`); body read = `formsize-4` bytes.

## BitMap (graphics/gfx.h) as consumed

BytesPerRow@0 (u16), Rows@2 (u16), Flags@4, Depth@5,
Planes[8]@8.  DecodePic/DecodeAnim index bm_Planes[0..23]
— i.e. they read **64 bytes beyond** the real structure
when a deep pic asks for it (only entries < pic depth or
bm_Depth are actually dereferenced).

## BMHD (20-byte chunk body)

w,h (u16) @0,2; left,top (i16) @4,6; depth,masking,
compression,pad @8,9,10,11; transparent (u16) @12;
xAspect,yAspect @14,15; pageWidth,pageHeight (i16) @16,18.
DecodePic reads w,h,depth,masking,compression.
Save worker writes left=x*8, top=y, xA=10, yA=11,
pageW=w*8, pageH=h.

## ANHD (as consumed)

Only `anhd_body[0]` — the ANIM operation byte — is read;
must equal 5.  (A standard ANHD is 32+ bytes; the library
ignores the rest.)

## DLTA (op-5 body)

`dlta_body[0..depth-1]` — ULONG plane-stream offsets,
relative to `dlta_body` itself; 0 → plane untouched.
Each stream is a per-column op sequence: for each of
BytesPerRow byte-columns, a count byte N then N op bytes
(+ operands).  Ops: 0 → replicate (count,value); 1..127 →
skip that many rows; 0x80..0xff → (op&0x7f) literals
written down the column.

## InitStruct datatab (8-bit-offset form)

```
a0 08 09 00          INITBYTE(8)  = 9   ln_Type   (+pad)
80 0a xx xx xx xx    INITLONG(10) = libname
a0 0e 06 00          INITBYTE(14) = 6   lib_Flags (+pad)
90 14 00 13          INITWORD(20) = 19  lib_Version
90 16 00 01          INITWORD(22) = 1   lib_Revision
80 18 xx xx xx xx    INITLONG(24) = idstring
00 00 00 00          terminator
```

Note the pad byte after every INITBYTE entry — entries are
even-aligned.  16.4 used the 24-bit extended forms
(e0/d0/c0) instead.
