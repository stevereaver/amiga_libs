# 68020.library 40.1 (MMU) — OKF index

`$VER: 68020.library 40.1 (4.12.99) (c) 1999 The MMU.lib
development group, THOR` — the MMULib 68020 CPU driver.

Unlike the 680x0.library dispatcher (reconstructed in
`../680x0_47.2.library`), this driver is a **system vector
patcher**: LibInit verifies the CPU is exactly a 68020, then
SetFunction-patches eleven exec/device vectors (CacheClearU
trampolines on the lib/dev/resource/task/int-server entry
points, an INTENA-based GetMsg reimplementation, a
recoverable-alert AddConfigDev patch, a BeginIO icache flush,
and a ColdReboot hook that shuts the PMMU down) and — only
when an FPU is present — installs TRAP #0..#6 exception
handlers through a Supervisor routine that writes both the
VBR-based and the absolute low-memory vector slots.

- Binary: `binary/68020_40.1(MMU).library` — 2188 bytes, m68k,
  two hunks (CODE 0x54c / DATA 0x200), AUTOINIT.
- Reconstruction: `source/` — `68020.c` (init/lifecycle/
  PatchTable drivers/FPUControl), `68020_patch.s` (patch
  stubs, supervisor body, TRAP handlers — PMMU/FPU/VBR
  instructions plus PC-memory-indirect operands that C cannot
  express), `68020_lib.s` (RomTag, AUTOINIT InitTable, functab,
  strings, patch tables).
- InitTable at data+0: `{dsize 0x70, functab->data+0x10,
  datatab NULL, initfunc->code+0x4a}`; the library header is
  filled by hand.
- 37 functab entries: four standard vectors, ~29 dead stubs
  raising Alert(0x3f000001), FPUControl at -222.

## Contents

- `functions/vectors.md` — LVO map, init flow, patch tables,
  trap-handler semantics
- `structures/layout.md` — Lib68020Base, hunk map, patch
  region and patch-record formats
- `findings/defects.md` — quirks (conditional GetMsg tail,
  dead vectors alert, unpatch scope, CPU-gate exactness)
- `log.md` — RE session log incl. oracle verification matrix
