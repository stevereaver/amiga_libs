# mathieeedoubtrans_40.6_040_.library

"mathieeedoubtrans 40.6 (7.4.95) for 68040", "(c) 1995 by Martin
Berndt" — IEEE-double transcendental lib, 68040 build. 5928B.

- Flat CODE hunk (0x59e longs), AUTOINIT, resident@h0+4,
  RELOC32 tail (31 slots ->h0).
- InitTable@h0+0x7e: dsize 0x2c, ftab@h0+0x8e (21 abs-long
  vectors), dtab@h0+0xe6, initfn@h0+0x108.
- Unlike the FPU sibling, uses 68040 fast-FPU insns: fsmove/
  fssqrt/fsdiv/fdmul etc + fmovem.x register save/restore.
