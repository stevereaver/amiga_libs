# xpkHUFF 0.62 — library vectors

AUTOINIT library (`RTF_AUTOINIT`), **absolute-longword**
function table (10 entries + -1 terminator) — unlike the
word-offset tables of xpkZENO/xpkSQSH-1.2 siblings.

## Vector map (original)

| LVO  | Entry (orig) | Notes                                          |
|------|--------------|------------------------------------------------|
| -6   | 0x368 LibOpen    | `addq.w #1,32(a6); bclr #3,14(a6); movel a6,d0`|
| -12  | 0x376 LibClose   | `moveq #0,d0` first; `--OpenCnt`; if 0 & DELEXP -> `bsr 0x38a` |
| -18  | 0x38a LibExpunge | see below — DELEXP handled correctly           |
| -24  | 0x3d0 zero stub  | `moveq #0,d0; rts`                             |
| -30  | 0x3e0 XpksPackerInfo | `movel a6,d0; addi.l #38,d0` -> lib+0x26   |
| -36  | 0x3ea XpksPackChunk  | moveml wrap -> `bsr 0x414` Huffman packer  |
| -42  | 0x3f6 null       | **bare `rts`** — d0 passthrough                |
| -48  | 0x3f8 null       | bare `rts`                                     |
| -54  | 0x3fa XpksUnpackChunk| moveml wrap -> `bsr.w 0x73e` Huffman unpacker|
| -60  | 0x408 null       | bare `rts`                                     |

The pack/unpack wrappers are plain compiler prologues
(`moveml d1-d7/a1-a6,-(sp); bsr body; moveml (sp)+,same; rts`)
— no observable effect beyond the body.

## LibOpen (0x368)

    addq.w  #1,32(a6)           ; lib_OpenCnt++
    bclr    #3,14(a6)           ; lib_Flags &= ~LIBF_DELEXP
    move.l  a6,d0
    rts

## LibClose (0x376)

    moveq   #0,d0               ; return 0 by default
    subq.w  #1,32(a6)
    bne     out
    btst    #3,14(a6)           ; DELEXP?
    beq     out
    bsr.s   0x38a               ; -> LibExpunge body
  out:
    rts

## LibExpunge (0x38a) — deferred expunge WORKS (cf. 0.64 bug)

    tst.w   32(a6)              ; OpenCnt == 0?
    bne     defer               ; -> bset #3,14(a6); moveq #0,d0; rts
    movem.l d1-d7/a0-a6,-(sp)
    movea.l a6,a5
    bsr.s   0x3d4               ; dead call to _subnoop (moveml/nop/moveml)
    movea.l a6,a5               ; (redundant reload)
    movea.l a6,a1
    movea.l 4.w,a6
    jsr     -252(a6)            ; Remove(lib)
    move.l  34(a5),d7           ; seglist from lib+34
    movea.l a5,a1
    moveq   #0,d0
    move.w  16(a5),d0           ; NegSize
    suba.l  d0,a1
    add.w   18(a5),d0           ; + PosSize
    movea.l 4.w,a6
    jsr     -210(a6)            ; FreeMem(lib-NegSize, total)
    move.l  d7,d0               ; return seglist
    movem.l (sp)+,d1-d7/a0-a6
    rts

Unlike the 0.64 descendant, the `bset #3,14(a6)` in the defer
path runs while a6 still holds the LIBRARY base, so deferred
expunge actually fires on Close-to-zero (verified: flags 6->14,
then Close returns the seglist 0x5a0000 with Remove+FreeMem
logged).

## LibInit (initfn, 0x1bc)

- double `moveml d0-a6` save (two pushes, two pops).
- stores `a0` (seglist) at **lib+34**.
- builds the XpkMode record at **lib+0x7e** (40 bytes;
  writes only 8 of the 10 `xm_Description` bytes — "normal\0\0",
  the last 2 stay uninitialised).
- builds the XpkInfo at **lib+0x26** (88 bytes) with
  pc-relative `lea` string pointers, ID 'HUFF', flags 0x2009,
  Max/DefPkInChunk 0xfffe, Min 1, DefMode 50, ModeDesc ->
  lib+0x7e, 6 reserved longs cleared.
- returns libbase (d0 preserved).

## Segment list

Stored at **lib+34** by LibInit (a normal private field — same
convention as xpkSQSH_1.10), read back by LibExpunge.

## Dos entry stub (code+0x00, runs when exec'd from CLI)

    moveq   #0,d0
    lea     "dos.library"(pc),a1
    movea.l 4.w,a6
    jsr     -552(a6)            ; OpenLibrary
    tst.l   d0; beq out
    movea.l d0,a6
    jsr     -60(a6)             ; Output()
    move.l  d0,d1
    move.l  #msg,d2             ; relocated
    move.l  #128,d3             ; fixed length
    jsr     -48(a6)             ; Write
    movea.l a6,a1
    movea.l 4.w,a6
    jsr     -414(a6)            ; CloseLibrary
  out: moveq #0,d0; rts

The 128-byte message (code+0x44..0xc3) is
`"\nYou can't execute xpkHUFF.library V\xa00.62!\n($DATE:\xa0
Mon Aug 10 10:31:44 1992 by M.Zimmermann
(zimerma@helios.ibr.cs.tu-bs.de))\n\n"` + NUL.  Uses the
`\xa0` non-breaking space after "V"/":" like the id string.

## Dead tail (0x40a)

`{u32 0, u16 8, u32 0x32e}` — 10 unreferenced bytes after the
-60 stub; remnant of some deleted table.

## Header fields

- dataSize 0xa8, negSize 0x3c (10 vectors), posSize 0xca
- lib version/revision 0/62, type NT_LIBRARY, flags 6
- `rt_IdString` -> code+0xf4, skipping the `$VER: ` prefix
  that sits at code+0xee (full version-command string
  `"$VER: xpkHUFF.library\xa0V\xa00.62 ($DATE:...))"`).
