# 68020.library 46.3 — RE Log

- Started AMIGALIBS-124. 2,412 bytes, two hunks (CODE 1,512 / DATA 536).
  ~89% code similarity to the already-reconstructed 68020 43.2.
- Diffed raw CODE hunks (custom objdump binary disasm): same skeleton —
  RomTag, dead-vector stub, alert helper, LibInit, PatchTable/
  UnpatchTable, patch region, 68881 handlers — plus ~200 bytes of new
  init-tail code.
- New 46.3 pieces decoded: Supervisor({nop;rte}) gated on NOMMU,
  mmu.library -150 + two -282 calls (ids 0x83e00403/0x83e00405) with a
  16-byte object copy, and Forbid+FindName(LibList,"p5emu.library")+
  call of p5emu's -24 vector (a1 = own base).
- ColdReboot supervisor body differs from 43.2: added a `cmpiw
  #0x4e70,a0@(-2)` normalization for reset vectors that already include
  the `reset` opcode, and a `cmpal #0x200000` gate that skips `reset`
  when the patch code itself is below 2 MB.
- Private base grew to 0x74 (new unused longword at +0x50; TrapSave now
  at 0x54-0x6c — exception table save offsets updated accordingly).
- Functab identical in shape: Open/Close/Expunge/Null at -24/DeadVectors
  -30..-216/FPUControl -222, -1L terminated.
- Data hunk gains "p5emu.library"; idstring bumped to 46.3
  (30.04.2017); patch tables identical (ColdReboot -726 + 10 exec/input
  records).
- Wrote C + asm reconstruction (68020.c, 68020_lib.s, 68020_patch.s)
  reusing the 43.2 framework.  Built with m68k-amigaos-gcc -m68020.
- machine68k oracle: full init matrix identical — CPU rejects, FPU on/
  off, mmu present/absent, mmu -150 NULL, p5emu absent, and every
  OpenLibrary/FindName failure path (alert codes 0x3f02800a/0x0c/0x21/
  0x3e + unpatch + closelib order + freemem 338).
- ColdReboot vector exercised: Disable/CacheControl/Supervisor/
  Alert(0x3f000002)/Enable sequence identical; exception vectors land
  in the VBR table in the documented order; GetMsg early-out and
  dead-vector alert verified; FPUControl read-modify-write verified.
