# mathieeesingtrans_40.6_040_.library

"mathieeesingtrans 40.6 (7.4.95) for 68040", "(c) 1995 by Martin
Berndt" — IEEE-single transcendental lib, 68040 build. 5984B.

- Flat CODE hunk (0x5ac longs), AUTOINIT, resident@h0+4,
  RELOC32 tail (31 slots ->h0).
- InitTable@h0+0x7e: dsize 0x2c, ftab@h0+0x8e (abs-long
  vectors), dtab@h0+0xe6, initfn@h0+0x108 — same table shape as
  the doubbas/doubtrans 40.6 040 builds.
- 68040 fast-FPU insns (fs*/fd*, fmovem.x) throughout.
