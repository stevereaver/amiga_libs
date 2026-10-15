---
type: Function
title: bitmap.library 1.4 vector map
tags: [lvo, functab]
---

# bitmap.library vectors (long functab @code+0x9c, -1 terminator)

All library functions use **register args** (not a stack calling
convention), matching Reksten's assembly API style.

| LVO | target | reg args | role |
|-----|--------|----------|------|
| -6  | 0x0c4 | A6=lib | Open: cnt++, ret lib |
| -12 | 0x0d6 | A6=lib | Close: cnt--, expunge if LIBF_DELEXP |
| -18 | 0x100 | A6=lib | Expunge: deferred (flags|=8) if open; else CloseLibrary(gfx)+Remove -> seglist |
| -24 | 0x000 | - | reserved stub (moveq#0/rts at code+0) |
| -30 | 0x1b6 | A1=bm | **FreeBM**: free 40B bitmap struct + planes (FreeBitMap if gfx>=39) |
| -36 | 0x232 | D0=w,D1=h,D2=depth | **AllocBM** -> D0: 40B struct+planes (or AllocBitMap if gfx>=39) |
| -42 | 0x306 | A1=param blk | **Scale**: two-phase BltBitMap stretch; tmp bm from hunk-1 alloc if blk+8==0 |
| -48 | 0x862 | A2={w@0 step,w@2 count} | **RowTable** -> D0: AllocMem(count*4), entries = i*step |
| -54 | 0x8a4 | A1=ptr,A2=desc | FreeMem(A1, (w@2(A2))*4) |
| -60 | 0x69c | D0=color,D1=x,D2=y,A2=bm,A3=rowtab | **PutPixel**: chunky byte -> planar bit in every plane |
| -66 | 0x7b0 | D1=x,D2=y,A2=bm,A3=rowtab | **GetPixel** -> D0: planar bits -> chunky byte |
| -72 | 0x8bc | D1=x,D2=y,D3=w,D4=h,D5=?,A2=bm,A3=rowtab,A4=chunky | **PutRun**: write a run of chunky pixels |

## The 40-byte bitmap struct (A2/A1 args)

Custom struct compatible with `struct BitMap` field layout for the
fields used: `w@0`=BytesPerRow, `w@2`=Rows, `b@5`=Depth,
`+8`=Plane ptrs[8].  AllocBM (<gfx39) calls InitBitMap(-390) then
allocs `depth` planes of `rowbytes*height` with MEMF_CHIP|
MEMF_CLEAR (0x10002).  FreeBM frees planes `w@0*w@2` bytes each
then 40B struct.  >=gfx39 paths delegate to AllocBitMap(-918) /
FreeBitMap(-924).

## Scale param block (A1)

`+0` src bm ptr, `+4` dst bm ptr, `+8` tmp bm ptr (0 -> allocated
via -36 then freed), `+12/14` src w/h, `+16/18` dst w/h,
`+20..+30` coord/crop words, `b@33` flags: bit0 = column-major
second pass, bit1 = rowwise path.  Ret D0=0 on degenerate dims.
Observed: 4:1 src -> vertical strips via tmp bm, then tmp -> dst.
