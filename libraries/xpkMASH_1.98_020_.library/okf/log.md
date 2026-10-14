# xpkMASH.library 1.98 (020) — reconstruction log

- Parsed single CODE hunk; decoded RomTag (AUTOINIT v1 rev 98),
  InitTable (dsize 0x4a, absolute-long functab, datatab, initfn).
- Full disassembly; transcribed to gas asm (`source/xpkMASH.s`).
  gas relaxations worked around with raw `.short`: `movea.l 0(An),Am`
  explicit-zero displacement and the `move.b (Ax)+,(Ay)+` forms.
- `source/Makefile` + in-recipe linker script produce a byte-identical
  library: MD5 `b92fd3db12b87e806f85949130439ef0`.
- `work/oracle.py`: machine68k harness — hunk loader, fake exec with
  AllocMem bump arena / FreeMem / Remove list-splice traps, InitStruct
  application, `Done` endtrap at 0x7f0 (module-level class;
  `MachineEndExecution` is not an exception type in this machine68k).
  Trap tids are process-global → orig/rebuilt runs are separate
  subprocesses via `run_oracle.py` + `difftest.py`.
- Result: report + 40 packed streams identical (20 cases × modes 100/0,
  round-trips byte-exact).
- `work/randtest.py` (Lib-class oracle) with N=150: 740 case×mode
  comparisons orig vs rebuild — packed streams and unpack round-trips
  byte-identical, **0 failures**.
- Note: the bytes at code+0x356 decode as `chk.w (a0),d5` but are dead
  alignment fill — the clear loop is entered via `bsr.w $358` in both
  builds (000 uses fill word 0x001c there).  No CPU gate in LibInit.
- Cross-build: packed streams identical to the 000 build; only the
  `_020` id/long-name strings differ.
