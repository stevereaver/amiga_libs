# xpkHUFF 0.64 — library vectors

AUTOINIT library (`RTF_AUTOINIT`), **absolute-longword**
function table (10 entries + -1 terminator) — unlike the
word-offset tables of xpkZENO/xpkSQSH siblings.

## Vector map (original)

| LVO  | Entry (orig) | Notes                                          |
|------|--------------|------------------------------------------------|
| -6   | 0x09e LibOpen    | `++OpenCnt; bclr #3,14(a6); return base`     |
| -12  | 0x0ac LibClose   | `--OpenCnt`; if 0 & DELEXP flag -> Expunge   |
| -18  | 0x0c0 LibExpunge | see below — contains the a5/a6 bug           |
| -24  | 0x100 null       | `moveq #0,d0; rts`                             |
| -30  | 0x134 XpksPackerInfo | returns descriptor APTR (code+0x104)     |
| -36  | 0x13c XpksPackChunk  | Huffman packer                             |
| -42  | 0x130 null       | PackFree — dead stub, returns 0              |
| -48  | 0x130 null       | PackReset — dead stub                        |
| -54  | 0x474 XpksUnpackChunk| Huffman unpacker                         |
| -60  | 0x130 null       | UnpackFree — dead stub                       |

## LibExpunge — the ExecBase+14 bug (0x0c0)

    movem.l d1-d2/a5,-(sp)
    movea.l a6,a5              ; a5 = lib
    movea.l 4.w,a6             ; a6 = SysBase
    tst.w   0x20(a5)           ; OpenCnt == 0?
    beq     real_expunge
    bset    #3,14(a6)          ; *** sets DELEXP on ExecBase+14,
                               ;     NOT lib->lib_Flags ***
    moveq   #0,d0
    bra     out
  real_expunge:
    move.l  pc-rel cell,d2     ; code+0x7a: seglist (see below)
    movea.l a5,a1
    jsr     -252(a6)           ; Remove(lib)
    bsr     0x130              ; dead call to the null stub
    moveq   #0,d0
    movea.l a5,a1
    move.w  0x10(a5),d0        ; NegSize
    suba.l  d0,a1
    add.w   0x12(a5),d0        ; + PosSize
    jsr     -210(a6)           ; FreeMem(lib-NegSize, total)
    move.l  d2,d0              ; return seglist
  out:
    movem.l (sp)+,d1-d2/a5
    rts

Because the DELEXP bit lands on ExecBase, `LibClose` at
opencnt==0 finds lib flag bit 3 clear and returns 0 — deferred
expunge is unreachable in practice.  The reconstruction
reproduces the bug verbatim (`EXECBASE[14] |= 8`).

## Segment-list cell

The library keeps its seglist in a **code-resident** cell at
code+0x7a (a relocated long inside what looks like library data
space), not in lib+34.  `LibInit` (at the InitTable initfn)
stores `a0` there.  `LibExpunge` reads it back pc-relative.
The reconstruction keeps `_segcell` in the asm skeleton.

## LibInit (initfn)

- stores `a0` (seglist) into the code cell via a pc-relative
  `move.l` (relocated by the linker).
- contains two `bsr` calls landing on the bare `rts` at 0x132 —
  dead calls, presumably vestigial subresource inits.
- returns libbase (d0 preserved).

## Header fields

- dataSize 0x22, negSize 0x3c (10 vectors), posSize 0x44
- lib version/revision 0/64 ("0.64"), type NT_LIBRARY, flags 6
