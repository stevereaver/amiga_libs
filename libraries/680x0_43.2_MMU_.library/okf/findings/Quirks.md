---
type: Finding
title: Quirks and reconstruction notes
description: Non-obvious behaviours recovered from the binary.
timestamp: 2026-10-10T18:00:00Z
---

# Quirks

- **rt_EndSkip = 0.**  The RomTag EndSkip field is stored as literal
  0 with no relocation entry (not a pointer into the module as is
  usual).  Reproduced verbatim in `source/680x0_lib.s`.
- **Never expunges.**  LibExpunge is a `return 0` stub and LibClose
  only decrements the counter.  The library frees its own base
  memory only when *init* fails (missing exec V36 or missing CPU
  driver) - a self-expunge on the failure path.
- **Init requires the CPU driver.**  LibInit builds
  `"680N0.library"` on the stack (patches the 'x' of "680x0.library"
  with the CPU digit) and `OpenLibrary()`s it with a minimum version
  of 40.  The driver stays open for the lifetime of the
  system; failure expunges 680x0.library itself.
- **CPU/FPU/MMU types are ASCII digits**, not bit masks: '0'..'4',
  '6' (and 'A' on Apollo for 47.2).  See Mu680x0Libs
  `Include/libraries/680x0.h` (CPUTYPE_*/FPUTYPE_*).
- **68060 detection is a trap probe, not AttnFlags.**  A supervisor
  callback (cpuprobe.s) redirects the VBR at a fake stack vector
  table and executes `movec pcr,d1`; illegal instruction / line-F /
  vector-31 exceptions land on a trampoline that reports failure.
- **SetFPUExceptions guards the LVO range**: the driver must have
  `lib_Version >= 40` *and* `lib_NegSize >= 0xde` before the -222
  (FPUControl) slot is called.
- **'THOR' magic**: LibInit stores the longword 0x54484f52 ('THOR')
  at base+0x24 - the author signature, never read afterwards.
- **Reconstruction deviations**: GCC code layout, register
  allocation and instruction selection differ from the shipped
  binary (compiled with a different toolchain).  Semantics match;
  the .data hunk is byte-identical except for the relocated vector
  pointers.  `movew` pairs replace the original single `movel` for
  version/revision.
