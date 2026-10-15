# memorymanage.library — RE log

## 2025 — session

- IDA/IRA disassembly; all `f`-line DC.W resolved as 68030 PMMU
  ops (`pmove`/`pflusha`/`ptestr`) and indexed-EA insns with ext
  word `1400`/`1403` (d1.w*4 [+3]).
- Identified 3-level page table: root 128×32MB, B 128×256KB,
  C 64×4KB; alloc sizes 0x220/0x120 (table+align+16B node).
- PMMU supervisor bodies verified byte-exact:
  `ptestr #1,a0@,7,a1` = `f010 9f31`; `pmove a0@,crp` = `f010 4c00`,
  etc. GNU as accepts `ploadw #0,a0@`/`ptestr #1,a0@,7,a1` forms.
- mm_map transcribed verbatim in asm (contains an alloc-fail
  control-flow defect that C cannot express faithfully).
- Lifecycle + enable/disable + ctx save/load + vatophys in C;
  `Supervisor()` via a5=code convention, `-ffixed-a5` to keep GCC
  off the ABI register.
- Build: `m68k-amigaos-gcc -m68030 -O2 -ffixed-a5 -nostdlib`.
- Verified: all 11 vectors resolve; header/functab/strings correct;
  mm_map instruction-for-instruction identical to original;
  mm_enable/disable codegen faithful (dbf fill, `tst.l An` opcodes,
  foreign-ctx byte-patch sequence all match semantics).
