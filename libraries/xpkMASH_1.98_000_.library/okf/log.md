# xpkMASH.library 1.98 (000) — reconstruction log

- Parsed single CODE hunk; decoded RomTag (AUTOINIT v1 rev 98),
  InitTable (dsize 0x4a, absolute-long functab, datatab, initfn).
- Full disassembly; transcribed to gas asm (`source/xpkMASH.s`).
  gas relaxations worked around with raw `.short`: `movea.l 0(An),Am`
  explicit-zero displacement and the `move.b (Ax)+,(Ay)+` forms.
- `source/Makefile` + in-recipe linker script produce a byte-identical
  library: MD5 `1527b4f331464f3013ba90ca44a91e54`.
- `work/oracle.py`: machine68k harness — hunk loader, fake exec with
  AllocMem bump arena / FreeMem / Remove list-splice traps, InitStruct
  application, `Done` endtrap at 0x7f0 (module-level class;
  `MachineEndExecution` is not an exception type in this machine68k).
  Trap tids are process-global → orig/rebuilt runs are separate
  subprocesses via `run_oracle.py` + `difftest.py`.
- Result: report + 40 packed streams identical (20 cases × modes 100/0,
  round-trips byte-exact).
