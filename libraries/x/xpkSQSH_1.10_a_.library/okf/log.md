# xpkSQSH 1.10(a) — reconstruction log

- Structure: single hunk, 701 longs = 2804 B code (vs 1.00's 525/2100).
  Functab/InitTable byte-identical to 1.00's (same 10 absolute longs,
  same target offsets).
- Code diff vs 1.00: identical up to code 0x3d7 (modulo shifted
  wrapper entry 0x2fc, a 3-long data block at 0x2f2, and the 0x2e8
  `bsrw` decoder target 0x762); wholesale rewrite 0x3d8–0x833
  (encoder core) + appended region 0x834–0xaf4.
- The appended region is the btst-loop decoder — byte-identical to
  the dead overlay in xpkSQSH_1.10.library (confirming that file is a
  damaged repack of THIS build).
- Disasm shows ZERO bitfield instructions — (a) is the 68000 build.
  Cost div/mul uses divu.w/mulu.w.
- First oracle run: all outlens identical to 1.00; all 16 streams
  byte-identical to the 1.00 streams — codec semantics unchanged.
- Reconstruction: 1.00 codec source + divuw/muluw asm helpers for the
  cost arithmetic (68000 lacks 32/32 div and 32x32 mul), skeleton from
  the 1.10(older) twin (rev 10, same idstr/longname), built -m68000 —
  object contains no bitfield instructions, matching the original.
- machine68k (M68020): rev=10, idstr/descriptor correct, PackerInfo ->
  lib+0x26. 16/16 streams byte-identical; 11 round-trips; 5 rejects
  return -17.
