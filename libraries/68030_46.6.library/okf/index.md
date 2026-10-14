# 68030.library 46.6 (MMU) — OKF Index

`$VER: 68030.library 46.6 (18.02.2021) (c) 1999-2016 The MMU.lib development group, THOR`

MMULib CPU driver for the plain 68030, by THOR's MMU.lib development
group.  Sibling of `68020_46.4` (and the 40.1/43.2 lineage) built for
the 68030's internal PMMU instead of the 68020's external-MMU model.
Direct evolution of `68030_46.5` (which itself only added an init-time
`CacheControl(0x2101,0x2101)` and new super_tt constants over 46.3).
46.6 adds **MMU-SuperKickstart detection**: init probes
`FindResident("MMU-SuperKickstart")` and sets bit0 of a new flag byte
at lib+0x2a; when set, the ColdReboot patch skips the whole
Disable/CacheControl/Supervisor/Alert/Enable sequence and tail-calls
the original vector — a kickstart already running from RAM needs no
PMMU shutdown before reset.  lib_Revision 5→6.

The library is an exec/intuition-internal patcher: it refuses to stay
resident on anything but an exact 68030 (AFF_68030 set, AFF_68040
clear), then installs a set of exec vector patches (CacheClearU
trampolines on AddLibrary/CloseLibrary/AddDevice/AddResource/AddTask/
AddIntServer/SetIntVector, an INTENA-based GetMsg replacement, an exec
private-slot -36 trampoline that reads INTREQR, a ColdReboot hook that
writes the PMMU transparent-translation registers and optionally
switches the PMMU off before resetting — or short-circuits entirely
under SuperKickstart), patches input.device BeginIO to flush the icache
on IND_ADDHANDLER, installs 68881/68882 exception handlers for FPU
vectors 48-54 when an FPU is present, calls into mmu.library
(-150/-282) to copy 16 bytes between two mmu.library objects, enables
both CPU caches via CacheControl(0x2101,0x2101) (carried from 46.5)
and expunges p5emu.library from the library list.

## Hunks

| hunk | type | size | contents |
|------|------|------|----------|
| 0 | CODE | 1612 | entry stub, RomTag, stubs/helpers, init, patch region, FPU handlers |
| 1 | DATA | 552 | InitTable, function table, strings (incl. `"MMU-SuperKickstart"`), patch record tables, exception table |

Like the 68020 siblings, the entire AUTOINIT block (InitTable, function
table, strings, patch tables) lives in the DATA hunk; the code hunk
references it through absolute-long relocations.

## Documents

- `functions/vectors.md` — the 37 library vectors and the internal entry points
- `structures/layout.md` — private library base, patch records, exception table
- `findings/defects.md` — quirks, dead code and shipped inconsistencies
- `log.md` — reverse-engineering log

## Status

Reconstruction complete (`source/68030.c`, `68030_lib.s`,
`68030_patch.s`, `Makefile`).  machine68k oracle differential-verified
against the original for: init happy path (with/without FPU, MMU type,
mmu.library object, p5emu.library), all CPU rejects (040/020/000), all
OpenLibrary/FindName failure paths with the alert codes
0x3f02800a/0x0c/0x21/0x3e, the ColdReboot vector in both modes
(SuperKickstart absent → disable/CacheControl/Supervisor/Alert-
3f000002/enable; present → bare tail-call to the old vector with
skflags=01 set at lib+0x2a), the Supervisor TT write on NOMMU
(TT0=0x8514 / TT1=0x00ff0125 — constants verified byte-exact since
`pmove` is invisible to the call-log oracle), the GetMsg early-out,
the dead-vector alert, the exception-vector install into the VBR table
(vectors 48-54 plus the absolute low-memory mirror), the trampoline
chain ordering, the BeginIO cmd-9 gate, and all lifecycle vectors.
Every case matches.
