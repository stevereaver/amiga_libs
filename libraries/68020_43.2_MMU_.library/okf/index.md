# 68020.library 43.2 (MMU) — OKF index

`$VER: 68020.library 43.2 (28.05.2014) (c) 1999 The MMU.lib
development group, THOR` — the MMULib 68020 CPU driver,
2014 revision of the 40.1 driver (sibling:
`../68020_40.1_MMU_.library`).

A **system vector patcher**: LibInit verifies the CPU is
exactly a 68020, then SetFunction-patches ten exec/device
vectors (CacheClearU trampolines on the lib/dev/resource/
task/int-server entry points, an INTENA-based GetMsg
reimplementation with an early empty-list check, a tail-call
trampoline on the **unpublished exec internal slot -36**
that reads INTREQR, a BeginIO icache flush, and a
ColdReboot hook that shuts the PMMU down, clears CACR/VBR
with `movec` and executes `reset`) and — only when an FPU is
present — installs the 68881/68882 FPU exception handlers
(vectors 48-54, VBR+0xc0..0xd8) through a Supervisor routine
that writes both the VBR-based and the absolute low-memory
vector slots.

Deltas over 40.1 (verified byte-level + oracle):

- expansion.library/AddConfigDev patch **removed** — the
  AddConfigDev alert (0x3f000015) is gone, though
  expansion.library is still opened and kept in lib+56.
- exec **-36** slot patched instead (a trampoline that pushes
  the old vector, performs a side-effect-free
  `tstw $dff01e` (INTREQR) and rts's into the original).
- pf_getmsg: early empty-list check
  (`lh_TailPred == &lh_Head`) before touching INTENA; the
  single-element-list quirk (returns 0, nothing unlinked)
  remains.
- super_coldreboot: after the pmove-off it zeroes CACR and
  VBR with `movec`, then `reset` before jumping into the ROM
  reset code — replacing 40.1's longer CacheControl-style
  tail.
- version 43, revision 2, idstring date 28.05.2014; data
  hunk 516 B (string +4 B), code hunk 1316 B.

- Binary: `binary/68020_43.2(MMU).library` — 2192 bytes, m68k,
  two hunks (CODE 0x524 / DATA 0x204), AUTOINIT.
- Reconstruction: `source/` — `68020.c` (init/lifecycle/
  PatchTable drivers/FPUControl), `68020_patch.s` (patch
  stubs, supervisor body, 68881 handlers — PMMU/FPU/VBR/
  movec/reset instructions plus PC-memory-indirect operands
  that C cannot express), `68020_lib.s` (RomTag, AUTOINIT
  InitTable, functab, strings, patch tables).
- InitTable at data+0: `{dsize 0x70, functab->data+0x10,
  datatab NULL, initfunc->code+0x4a}`; the library header is
  filled by hand.
- 37 functab entries: four standard vectors, ~29 dead stubs
  raising Alert(0x3f000001), FPUControl at -222.

## Contents

- `functions/vectors.md` — LVO map, init flow, patch tables,
  exception-handler semantics
- `structures/layout.md` — Lib68020Base, hunk map, patch
  region and patch-record formats
- `findings/defects.md` — quirks (GetMsg single-element tail,
  dead vectors alert, unpatch scope, vestigial INTREQR read,
  unused expansion open)
- `log.md` — RE session log incl. oracle verification matrix
