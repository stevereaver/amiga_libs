# xpkBZIP 41.2 — work log

- Parsed hunks: CODE 0x508 + DATA 0x314; 14 code→data + 18
  data→code + 19 data→data relocations.
- DATA hunk InitTable (absolute form): dataSize 0x32,
  funcs→+0x10, data→+0xec, init→h0+0xe.  Functab = 10
  absolute longs → h0 {0x46,0x5e,0x80,0xcc,0x144,0x1fc,
  0x32e,0x37c,0x38a,0x4b6} + -1.
- DATA+0xd0 decoded as a standard exec Resident: 0x4afc
  matchword, matchtag→self, endskip→+0x310, AUTOINIT v41
  NT_LIBRARY pri2, name→"xpkBZIP.library", idstr→$VER,
  rt_Init→+0x00 — the whole sublib is a proper exec library
  loaded by xpk.library via the normal AUTOINIT path.
- datatab: 24-bit-offset byte@8=9, byte@14=6, word@20=41,
  word@22=2; 8-bit long@10=name, long@24=idstr.
- Lifecycle: opencnt@32, DELEXP bit3@14, expunge via
  data+120 SysBase (redundant store) + lib+34 seglist.
  LibClose early exits branch INTO the operand of a dead
  `cmpi.w #0x7000,d0` where 0x7000 = moveq #0,d0.
- LibInit: lib→data+60, SysBase→lib+38, seglist→lib+34;
  initppc: SysBase→data+120, OpenLibrary("ppc.library",44)
  →data+124 AND lib+42.  Fail → exitppc + return 0.
- -30 returns APTR to XpkInfo (data+0x2b8, 88 B).
- Pack (a0=xsp): mode=(9+level)/10 min 1 via divu.l;
  out[0]=mode written BEFORE the 1..10 range check (-12);
  LoadObject("LIBS:ppc/xpkBZIP.elf")→args+64 (-33 on fail);
  lazy allocs only when ALL THREE bufs zero:
  buf52=mode*409600, buf56=mode*409600, buf60=0x40004 (-7
  on any missing, via the -42 free helper);
  frame={1,mode,src,dst+1,inlen,outsize,b52,b56,b60,0,0};
  RunFunction→args+16; UnloadObject; return 0.
- Unpack (a0=xsp): mode=src[0]; same checks/loads;
  bufs=mode*409600,mode*102400,mode*102400;
  frame={0,mode,src+1,dst,inlen,outsize,b52,0,0,b56,b60};
  ret -1→-17, -2→-5, !=outsize→-4, else 0 (0 via a
  mid-instruction moveq inside the dead cmpi operand).
- -42 PackFree = -60 UnpackFree minus the trailing
  `moveq #0,d0` — PackFree returns the last FreeVec residue.
- 10 XpkMode records (42 B), backward xm_Next chain anchored
  at the LAST record (" 100 K"): block sizes 1000..100 KB,
  upto 100..10, mem/speed/ratio measured values, names
  inline 8 B unterminated.
- Reconstruction: C API + asm skeleton/data hunk; GNU ld
  emits CODE+DATA hunks; oracle byte-identical including the
  mid-instruction quirk semantics (reproduced verbatim in
  LibClose via .byte trick).
- Caveat: gcc regasm param bindings are LOST on inlining —
  ppc helpers use explicit moveal/movel in the asm template.
