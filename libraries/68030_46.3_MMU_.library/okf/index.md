# 68030.library 46.3 (MMU) — OKF Index

`$VER: 68030.library 46.3 (30.04.2017) (c) 1999-2016 The MMU.lib development group, THOR`

MMULib CPU driver for the plain 68030, by THOR's MMU.lib development
group.  Sibling of `68020_46.3` (and the 40.1/43.2 lineage) built for
the 68030's internal PMMU instead of the 68020's external-MMU model.

The library is an exec/intuition-internal patcher: it refuses to stay
resident on anything but an exact 68030 (AFF_68030 set, AFF_68040
clear), then installs a set of exec vector patches (CacheClearU
trampolines on AddLibrary/CloseLibrary/AddDevice/AddResource/AddTask/
AddIntServer/SetIntVector, an INTENA-based GetMsg replacement, an exec
private-slot -36 trampoline that reads INTREQR, a ColdReboot hook that
writes the PMMU transparent-translation registers and optionally
switches the PMMU off before resetting), patches input.device BeginIO
to flush the icache on IND_ADDHANDLER, installs 68881/68882 exception
handlers for FPU vectors 48-54 when an FPU is present, and — as in the
other 46.3 builds — calls into mmu.library (-150/-282) to copy 16 bytes
between two mmu.library objects and expunges p5emu.library from the
library list.

## Hunks

| hunk | type | size | contents |
|------|------|------|----------|
| 0 | CODE | 1552 | entry stub, RomTag, stubs/helpers, init, patch region, FPU handlers |
| 1 | DATA | 536 | InitTable, function table, strings, patch record tables, exception table |

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
0x3f02800a/0x0c/0x21/0x3e, the ColdReboot vector (disable/
CacheControl/Supervisor/Alert-3f000002/enable sequence including the
TT-register pmove setup and the 2 MB reset gate), the Supervisor TT
write on NOMMU, the GetMsg early-out, the dead-vector alert, the
exception-vector install into the VBR table (vectors 48-54 plus the
absolute low-memory mirror at the same byte offsets), the trampoline
chain ordering, the BeginIO cmd-9 gate, and all lifecycle vectors.
Every case matches.
