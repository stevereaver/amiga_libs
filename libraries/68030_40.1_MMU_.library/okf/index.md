# 68030.library 40.1 (MMU) — OKF index

`$VER: 68030.library 40.1 (4.12.99) (c) 1999 The MMU.lib
development group, THOR` — the MMULib 68030 CPU driver,
sibling of `../68020_40.1_MMU_.library` (and the 43.2
variants `../68020_43.2_MMU_.library`).

A **system vector patcher**: LibInit verifies the CPU is
exactly a 68030, then SetFunction-patches eleven exec/device
vectors (CacheClearU trampolines on the lib/dev/resource/
task/int-server entry points, an INTENA-based GetMsg
reimplementation, a recoverable-alert AddConfigDev patch, a
BeginIO icache flush, and a ColdReboot hook that shuts the
030 PMMU down — TC *and* both transparent-translation
registers — and executes `reset` before jumping to the ROM
reset vector) and — only when an FPU is present — installs
the 68881/68882 FPU exception handlers (vectors 48-54,
VBR+0xc0..0xd8) through a Supervisor routine that writes
both the VBR-based and the absolute low-memory vector slots.

Deltas vs the 68020 40.1 driver (verified byte-level +
oracle):

- CPU gate checks **bit 3 clear / bit 2 set** (reject
  AFF_68040+, require AFF_68030) instead of bit 2/bit 1.
- super_coldreboot: three `pmove`s — TC, **TT0 and TT1**
  (the 030 MMU's transparent translation regs) — and the
  tail runs `reset; jmp a0@` instead of `nop; jmp a0@`.
- Patch region is 8 bytes larger; all stub fnoffs shift +8
  (see structures/layout.md); patch_lib at code+0x464.
- Everything else — init flow, patch tables, getmsg quirk,
  handlers, FPUControl, dead vectors — identical to 40.1.

- Binary: `binary/68030_40.1(MMU).library` — 2196 bytes, m68k,
  two hunks (CODE 0x52c / DATA 0x200), AUTOINIT.
- Reconstruction: `source/` — `68030.c` (init/lifecycle/
  PatchTable drivers/FPUControl), `68030_patch.s` (patch
  stubs, supervisor body, 68881 handlers), `68030_lib.s`
  (RomTag, AUTOINIT InitTable, functab, strings, patch
  tables).
- InitTable at data+0: `{dsize 0x70, functab->data+0x10,
  datatab NULL, initfunc->code+0x4a}`.
- 37 functab entries: four standard vectors, ~29 dead stubs
  raising Alert(0x3f000001), FPUControl at -222.

## Contents

- `functions/vectors.md` — LVO map, init flow, patch tables,
  exception-handler semantics
- `structures/layout.md` — Lib68030Base, hunk map, patch
  region and patch-record formats
- `findings/defects.md` — quirks (GetMsg single-element tail,
  dead vectors alert, unpatch scope, AddConfigDev alert)
- `log.md` — RE session log incl. oracle verification matrix
