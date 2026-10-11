# i2c_40.1.library — RE log

- IRA disasm -> work/i2c_40.1.asm; full decode of all 14 vectors,
  InitFunction, LAB_0033 (env config), LAB_0051 (PFC8584 init),
  epilogue, I2CIntr.
- Reconstructed in C (i2c.c) + asm skeleton (i2c_lib.s) with
  absolute-pointer functab and byte-exact datatab/string region.
- Verification: header/data region byte-identical modulo relocated
  pointers (0 diffs over 0x19c); I2CIntr codegen byte-identical to the
  original; all field offsets confirmed against the disasm
  (sys 118, cfgdev 122, seglist 126, clk 130, present 134, state 135,
  sdown 136, timeout 140, intr 150, intr2 172, is_Data 164).
- Fixes during review: SignalSemaphore is 46B (not 34) — removed bogus
  12-byte pad so sys lands at 0x76; delayed-expunge is base+0x43 bit3
  not lib_Flags; errtab must sign-extend (EXT.W bug reproduced);
  "???" string is 3 marks not 4; I2CXTAL compares low byte only.
- Inline-asm hurdles: FINDCFG d0 in/out conflict resolved by sharing
  one hard-bound d0 var; semaphore macros must not clobber their own
  bound regs.
- Plane: AMIGALIBS-77.
