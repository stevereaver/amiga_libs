---
type: Function
title: Library framework vectors
---
# Library framework

- `LibInit` (AUTOINIT initRoutine): stores the seglist at
  base+0x24, then fills XpkMode at base+0x80 and XpkInfo at
  base+0x28 with immediates (helper at 0x2fa) — no LVOs.
- `LibOpen` (-6): `lib_OpenCnt++`, clears flag bit 0
  (`bclr #8` wrap; see findings), returns base.
- `LibClose` (-12): `lib_OpenCnt--`; at zero, tests flag
  bit 0 and falls through to LibExpunge if set.
- `LibExpunge` (-18): if opencnt nonzero sets flag bit 0
  and returns 0; else Remove(-252) + FreeMem(-210) of
  negsize+possize and returns the seglist.
- `LibNull` (-24): `moveq #0,d0; rts` (ExtFunc slot).
- `LibRts` (-42/-48/-60): bare `rts` — PackFree, PackReset,
  UnpackFree are all no-ops (codec is stateless).
