# 68020.library 46.4 (MMU) — OKF Index

`$VER: 68020.library 46.4 (23.07.2017) (c) 1999-2016 The MMU.lib development group, THOR`

MMULib CPU driver for the plain 68020, by THOR's MMU.lib development
group.  Fourth generation of the 68020 MMU driver in this collection
(siblings: `68020_40.1`, `68020_43.2`, `68020_46.3`; the family also
includes 68030/040/060 variants).  This `(MMU)`-named binary is a
byte-identical copy of `libraries/68020_46.4.library` (md5
`bd2a5cd6901a2e3b7626ca7bd52ee7c7`, 2,424 bytes) — the same code was
shipped under both names.  This directory carries its own full
reconstruction (built from the same source set); the committed sibling
holds an equivalent bundle.  Tracked in AMIGALIBS-125.

The library is an exec/device patcher: it refuses to stay resident on
anything but an exact 68020 (AFF_68020 set, AFF_68030 clear), then
installs a set of exec vector patches (CacheClearU trampolines on
AddLibrary/CloseLibrary/AddDevice/AddResource/AddTask/AddIntServer/
SetIntVector, an INTENA-based GetMsg replacement, an exec private-slot
-36 trampoline that reads INTREQR, a ColdReboot hook), patches
input.device BeginIO to flush the icache on IND_ADDHANDLER, installs
68881/68882 exception handlers for FPU vectors 48-54 when an FPU is
present, copies 16 bytes between two mmu.library objects via -150/-282,
expunges p5emu.library from the library list and — new in 46.4 — calls
exec CacheControl(1,1) (CACRB_EnableI) after the vector patches to
re-enable the 68020 instruction cache.

## Hunks

| hunk | type | size | contents |
|------|------|------|----------|
| 0 | CODE | 1524 | entry stub, RomTag, stubs/helpers, init, patch region, FPU handlers |
| 1 | DATA | 536 | InitTable, function table, strings, patch record tables, exception table |

## Documents

- `functions/vectors.md` — the 37 library vectors and the internal entry points
- `structures/layout.md` — private library base, patch records, exception table
- `findings/defects.md` — quirks, dead code and shipped inconsistencies
- `log.md` — reverse-engineering log

## Status

Reconstruction complete (`source/68020.c`, `68020_lib.s`,
`68020_patch.s`, `Makefile`).  The gcc/ld build is behaviorally
identical but not file-byte-identical (CODE hunk 1,616 vs 1,524 bytes —
different codegen layout; the DATA hunk matches byte-for-byte at every
non-relocated word).  machine68k oracle differential-verified against
the original for: init happy path (with/without FPU, MMU, mmu.library
object, p5emu.library), the new CacheControl call placement, all CPU
rejects, all OpenLibrary/FindName failure paths with the alert codes
0x3f02800a/0x0c/0x21/0x3e, ColdReboot, the GetMsg early-out, the
dead-vector alert, and all lifecycle vectors.  `work/matrix.py` reports
MATRIX DIFF: CLEAN across 11 configurations.
