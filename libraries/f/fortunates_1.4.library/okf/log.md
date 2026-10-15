# fortunates.library 1.4 — work log

- Parsed original: 3 hunks — CODE 2516 B (h0), DATA 16 B (h1),
  BSS 152 B (h2); file 2976 B total. RomTag@h0+4, AUTOINIT v1,
  rt_Init -> h0+0xda, EndSkip -> h0+0x9d2.
- InitTable (h0+0xda): dsize 0x30, functab -> h0+0xea (17 absolute
  longs + ffffffff term), datatab -> h0+0x132, initfn -> h0+0x152.
- Full disasm: SAS/C-compiled fortune/ILBM image utility. 17 vectors;
  initfn opens 9 dependency libraries into BSS; FORM/RGB8/BMHD/BODY
  parsing, PackBits row/column decoders, bitplane interleave, ILBM
  BODY/FORM writer, ReqTools requester glue.
- Transcribed verbatim to fortunates_h0.s/h1.s/h2.s; linker script
  orders hunks CODE/DATA/BSS; fixup.py restores the original RELOC32
  grouping and flips the h2 record to HUNK_BSS.
- Fixes during bring-up: correct `subal d0,a3` (misread reg pair);
  absolute `jsr` / zero-displacement / `movel #imm,dn` forms raw-emitted
  to stop GAS canonicalization; `bles` not `bls` in _penmetric;
  _makeimg inner-loop label placement; EndSkip before the pad word;
  fixup.py needed the 0x3ec tag + BSS conversion.
- Build: byte-identical — MD5 05622c0c9f63d78bd77e0c7dd54925e1.
- Oracle: machine68k AUTOINIT harness, fake exec + 9 dep libs with
  real OpenLibrary/CloseLibrary/AllocVec/FreeVec semantics, FORM/RGB8
  fixture, PackBits fixtures, ReqTools request stubs. Exercised init,
  Open/Close, AvailMemCmp, BssPtr, FindTag hit+miss, LoadFile
  success+fail, ReqFortune, ShiftBit, PenMetric, UnpackRow, UnpackCol,
  Interleave, Interleave2, MakeBody, MakeImg file-write, Expunge
  teardown, deferred expunge — original vs rebuild traces identical.
