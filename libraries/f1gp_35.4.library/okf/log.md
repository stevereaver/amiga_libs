# f1gp 35.4 — work log

- Parsed hunk file: CODE 2216 B + DATA 104 B body / 196 B alloc + RELOC32.
- Decoded RomTag (non-AUTOINIT) and hand-written init: MakeLibrary via
  long-absolute vector table @code+0x1b4; identified as Oliver Roberts'
  F1GP runtime patcher library.
- Recovered all 8 vectors, all exec LVO call sites, patch-node layout,
  task-list F1GP detection (hunk sizes 844/908/1312/1392, magic 0x2a948).
- Reconstructed as pure 68k asm (`source/f1gp_lib.s`); iterative
  byte-diffing against the original:
  - forced absolute `lea` (x2), raw `movel #imm` opcodes (gas would
    relax to `moveq`), raw `subl`/`cmpl` opcodes, long-absolute
    `moveal 4:l,a6`, PC-relative `jmp` tail, forced absolute JSRs.
- `fixup.py` restores the DATA hunk declared size 26->49 longs and
  rewrites RELOC32 lists to the original non-sorted order.
- Final binary **byte-identical**: MD5 `69c0f71d33e8a60891b2c0824986b028`.
- `work/oracle.py` (machine68k, M68020): rt_Init -> MakeLibrary +
  AddLibrary + InitSemaphore traced; Open/Close/Expunge incl. deferred
  expunge (DELEXP flag then seglist return on close); AllocNode/
  FreeNode via semaphore; Checksum; FindPatch with empty task lists.
  Trace identical between original and rebuild.
