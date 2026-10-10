# Framework

## LibInit (@0xac, dataSize 0x26)

Stores the seglist argument (a0) at base+0x22, returns base.
No external libraries opened.

## LibOpen/Close/Expunge (@0xb4/0xc2/0xd4)

Standard AUTOINIT trio.  Close decrements OpenCnt and tail-
calls Expunge when it reaches 0 with LIBF_DELEXP set.
Expunge: `Remove(-252)` then `FreeMem(-210)` of
`base-negSize` for `negSize+posSize`; returns seglist.
Dead `moveal a5@(36),a6` at the top (SysBase reload that is
overwritten by `4.w` before any use).

## XpksPackFree (-42, @0x112)

If `xsp_Sub[0]` is set: `a1 = sub; d0 = a1@-` (size word at
buf[0] = 0x44004) then `FreeMem(-210)`.  Never clears
`xsp_Sub`, so a second PackFree would double-free (dead code
path in normal xpk flow).

## XpksPackerInfo (-30, @0x17e)

`lea 0x368,a0; movel a0,d0` -- static descriptor, no mode
selection logic.
