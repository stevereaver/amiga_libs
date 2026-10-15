# functions / vectors

Standard Froehling XPK sublibrary vector set, AUTOINIT word-offset
functab (offsets relative to the -1 marker at functab+0):

| LVO | hunk target (orig) | function |
|-----|--------------------|----------|
| -6  | 0xc2 | Open: `addq.w #1,32(a6); bclr #3,14(a6); move.l a6,d0` |
| -12 | 0xd0 | Close: dec opencnt -> null stub, or falls into expunge when DELEXP |
| -18 | 0xe2 | Expunge: DELEXP retry or Remove+FreeMem(negsize+possize), returns seglist |
| -24 | (0)  | null vector (functab entry 0) |
| -30 | 0x18c | XpksPackerInfo -> XpkInfo descriptor (orig 0x468) |
| -36 | 0x194 | XpksPackChunk -- encoder, 0x80004 lazy workmem |
| -42 | 0x120 | XpksPackFree -- `move.l 52(a0),d0; move.l -(a1),d0; FreeMem` |
| -48 | 0x138 | XpksPackReset -- downward movem fill (defective, see findings) |
| -54 | 0x3b8 | XpksUnpackChunk -- decoder |
| -60 | (0)  | null vector |

## LibInit (orig 0xac)
`movea.l d0,a1; move.l a0,34(a1); movea.l 4.w,a0; btst #1,297(a0);
beq.w <nullstub>` -- stores seglist at +0x22, gates on AFB_68020.

## XpkSubParams (a0 to the codec LVOs)
+0 InBuf, +4 InLen, +8 OutBuf, +12 OutBufLen (unused), +16 OutLen,
+20 Flags, +24 Number, +28 Mode, +32 Password, +36 LibVersion(w),
+52 xsp_Sub[4] (sub[0] = workmem+4)
