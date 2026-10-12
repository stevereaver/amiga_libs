# pointer 33.2 — RE log

- Parsed 3-hunk header: CODE 0x3e9 (0x197 lws), DATA|CHIP 0x400003ea
  (0x12 lws), DATA 0x3ea (0x16 lws).  RELOC32 records follow each hunk.
- RomTag @code+0x2a: MATCHWORD, RTF_AUTOINIT|NT_LIBRARY, v33,
  rt_Init = DATA-hunk offset +4 (InitTable), rt_EndSkip = 0.
- ID string `"NuPointerLibrary 33.2 (5 Jan 1991)\r\n"`; reserved -24
  vector resolves onto its `\r\n\0\0` tail.
- InitTable {0x8a, funcTab, 0, initFn@0x44}; data block + fixup list
  decode confirmed by IRA's SECSTRT_2 dump (embedded spec
  {img,16,16,-6,0,0}, prop list ILBM/BMHD+CMAP+GRAB, fixup {1,0x34}).
- IRA disassembly mapped: LibInit (copy+fixup+deps+fallback),
  PtrDepsInit, PtrSetPointer (intuition -270), PtrLoadSpec (full
  iffparse ILBM pipeline, per-BODY scan loop, CloseIFF+DOSClose
  cleanup), PtrFreeSpec (img then spec), expunge (cleanup + inline
  unlink + FreeMem).
- LVOs resolved against NDK headers: all 19 iffparse/dos/intuition/
  exec calls named.
- Reconstructed in C (pointer.c) + minimal resident-module asm
  (pointer_lib.s); custom linker script + chipflag.py reproduce the
  exact 3-hunk layout with the CHIP flag on hunk 1.
- Host harness (work/host.c, -m32, fake iffparse ILBM sim): all 8
  scenarios pass — good load {h16,w16,xo-3,yo-4,sz72}, SetPointer
  arg propagation, expunge, and embedded-spec fallback on dos-open
  failure / missing iffparse / parse failure / missing BMHD /
  compressed BMHD / missing GRAB.
- Codegen verified vs original: LibInit bytes, scan-loop shape,
  spec field writes, negated GRAB, cn_Size+8 alloc, CloseIFF and
  DOSClose sites all present.
