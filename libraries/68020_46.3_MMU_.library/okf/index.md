# 68020.library 46.3 (MMU) — OKF Index

`$VER: 68020.library 46.3 (30.04.2017) (c) 1999-2016 The MMU.lib development group, THOR`

MMULib CPU driver for the plain 68020, by THOR's MMU.lib development
group.  Third generation of the 68020 MMU driver in this collection
(siblings: `68020_40.1`, `68020_43.2`; the family also includes 68030/040/060
variants).

The library is an exec/intuition-internal patcher: it refuses to stay
resident on anything but an exact 68020 (AFF_68020 set, AFF_68030
clear), then installs a set of exec vector patches (CacheClearU
trampolines on AddLibrary/CloseLibrary/AddDevice/AddResource/AddTask/
AddIntServer/SetIntVector, an INTENA-based GetMsg replacement, an exec
private-slot -36 trampoline that reads INTREQR, a ColdReboot hook),
patches input.device BeginIO to flush the icache on IND_ADDHANDLER,
installs 68881/68882 exception handlers for FPU vectors 48-54 when an
FPU is present, and — new in 46.3 — calls into mmu.library (-150/-282)
to copy 16 bytes between two mmu.library objects and expunges
p5emu.library from the library list.

## Hunks

| hunk | type | size | contents |
|------|------|------|----------|
| 0 | CODE | 1512 | entry stub, RomTag, stubs/helpers, init, patch region, FPU handlers |
| 1 | DATA | 536 | InitTable, function table, strings, patch record tables, exception table |

## Documents

- `functions/vectors.md` — the 37 library vectors and the internal entry points
- `structures/layout.md` — private library base, patch records, exception table
- `findings/defects.md` — quirks, dead code and shipped inconsistencies
- `log.md` — reverse-engineering log

## Status

Reconstruction complete (`source/68020.c`, `68020_lib.s`,
`68020_patch.s`, `Makefile`).  machine68k oracle differential-verified
against the original for: init happy path (with/without FPU, MMU,
mmu.library object, p5emu.library), all CPU rejects, all OpenLibrary/
FindName failure paths with the alert codes 0x3f02800a/0x0c/0x21/0x3e,
the ColdReboot vector (disable/CacheControl/Supervisor/Alert-3f000002/
enable sequence incl. the 2 MB reset gate), the GetMsg early-out, the
dead-vector alert, the exception-vector install into the VBR table,
and all lifecycle vectors.  Every case matches.
