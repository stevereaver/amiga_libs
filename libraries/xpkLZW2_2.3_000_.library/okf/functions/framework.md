# Framework functions

## LibInit (@0xac)

`moveal d0,a1; movel a0,a1@(34); rts` -- stores the seglist
at base+0x22, returns the base in d0/a1.  Standard Froehling
sublibrary convention.

## LibOpen (@0xb4)

`addqw #1,lib_OpenCnt; bclr #3,lib_Flags; movel a6,d0; rts`.
Uses the CORRECT `bclr #3` (LIBF_DELEXP) -- unlike xpkCBR0
1.0's bit-8-on-byte quirk.

## LibClose (@0xc2)

```
subqw #1,a6@(32)        OpenCnt--
movel a6,d0
bne   -> return 0       (still open)
btst  #3,a6@(14)        DELEXP pending?
beq   -> return 0
fall through to LibExpunge
```

## LibExpunge (@0xd4)

If OpenCnt != 0: `bset #3,lib_Flags` (DELEXP), return 0.
Else: seg = base+0x22; `jsr a6@(-252)` Remove(lib); 
`jsr a6@(-210)` FreeMem(base-negsize, neg+pos); return seg.

## _start (@0x0) -- null vector target

`moveq #0,d0; rts` -- shared by the -24 and -60 slots.
Returns 0 for ExtFunc and XpksUnpackFree.
