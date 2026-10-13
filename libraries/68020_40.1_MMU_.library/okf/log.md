# 68020.library 40.1 (MMU) — RE log

- Hunk parse: HUNK_CODE 0x54c + HUNK_DATA 0x200, AUTOINIT.
  InitTable `{0x70, functab→data+0x10, 0, init→code+0x4a}`.
  37 functab entries; -1 terminator at data+0xa4.
- ID'd as THOR MMULib 68020 driver (cf. reconstructed
  680x0_47.2 sibling for family conventions and the mmu/
  utility/expansion/math/input dependency set).
- Disassembled init: manual header fill (no InitStruct),
  exactly-68020 CPU gate on AttnFlags low byte (reject
  AFF_68030, require AFF_68020), expansion+utility v37 opens,
  DeviceList FindName("input.device"), Table A ColdReboot
  patch, mmu.library open + GetMMUType (-54), optional
  Supervisor-based TRAP-vector install, Table B install of ten
  SetFunction patches, fail tail = alert + close opened libs +
  FreeMem(base-NegSize, NegSize+PosSize) + return NULL.
- Decoded patch tables A/B (liboff/vecoff/fnoff records,
  SetFunction driven, fn-4 slot holds the old vector) and
  table C (exception vectors, `{newfn, vbroff, saveoff}`
  records consumed by supervisor code writing both VBR and
  absolute low-memory slots).
- Identified pf_* stubs: CacheClearU trampolines (5× +
  2 moveml variants), INTENA-based GetMsg, BeginIO icache
  flush on IND_ADDHANDLER(9), recoverable-alert AddConfigDev,
  ColdReboot PMMU-off + ROM-reset jump, 7 TRAP handlers gated
  on FPUFlags byte + shared fsave/frestore fixup.
- Reconstructed in C (`68020.c`) + hand asm (`68020_patch.s`,
  `68020_lib.s`); `.word` encodings used for PC-memory-
  indirect operands and absolute `movel a2,@(0,d0:w)` gas
  can't emit.
- Oracle (machine68k, `work/oracle.py`): jump-table LVO model
  (slots are `jmp target`; SetFunction patches the target).
  - attn=0x02 (no FPU) + mmu=3: identical init call sequence
    (2 openlibs v37, Forbid/FindName/Permit, Disable/
    SetFunction(-726)/Enable, mmu open + GetMMUType, ten
    SetFunctions, Enable), identical lib header + priv block.
  - attn=0x12 (68881): additionally `Supervisor(super_excvec)`
    + CacheClearU before Table B; VBR/abs vector writes and
    lib+0x50..0x68 saves verified identical; all 7 installed
    TRAP handlers tail-call the saved vectors identically.
  - Fail paths identical: expansion→alert 0x3f02800a,
    utility→0x3f02800c, input.device→0x3f028021, mmu→
    0x3f02803e + UnpatchTable-A, all ending close-opened-libs
    + FreeMem(lib-NegSize, NegSize+PosSize) + return 0.
  - Patch stub behaviour identical post-init: pf_getmsg list
    surgery (INTENA path, tail-node semantics), trampolines
    → CacheClearU + oldvec, BeginIO cmd9 flush + oldvec,
    AddConfigDev alert + oldvec, FPUControl disable/enable +
    flag byte.
- Bug found & fixed in reconstruction: pinned a6 register var
  for SysBase collided with LibAlert's a6=lib parameter → gcc
  left a6=lib for CloseLibrary on the fail path (called a dead
  vector).  Captured entry-a6 into a normal pointer instead.
- Files: source/{68020.c, 68020_patch.s, 68020_lib.s,
  Makefile}; builds `68020.library` (m68k-amigaos-gcc -m68020
  -m68851 -m68881 -O2 -nostdlib).
