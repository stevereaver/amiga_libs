# 68030.library 46.6 — Vector Map

Function table: 37 absolute-longword entries + `-1` terminator, stored
in the DATA hunk at `hunk1+0x10` (InitTable at `hunk1+0`).

| LVO | code off (shipped) | entry | notes |
|-----|--------------------|-------|-------|
| -6   | 0x1ec | `LibOpen` | `bclr #3,lib_Flags` (clear DELEXP), `opencnt++`, return lib |
| -12  | 0x1fa | `LibClose` | `if opencnt: opencnt--`; return 0. Never expunges. |
| -18  | 0x208 | `LibExpunge` | `moveq #0/rts` — permanent no-op |
| -24  | 0x01e | `LibNull` | `moveq #0/rts` reserved stub |
| -30 .. -216 | 0x022 | `DeadVector` (×32) | `pea 0x3f000001; bsr LibAlertHelper` → Alert(0x3f000001), return 0 |
| -222 | 0x332 | `FPUControl` | `old=lib+34; lib+34=(old&~mask)|(flags&mask)` under Disable/Enable; returns old |

## Internal entry points (code hunk)

| off | role |
|-----|------|
| 0x00 | `moveq #-1,d0/rts` CLI bootstrap stub |
| 0x04 | RomTag (RTF_AUTOINIT, ver 46, rt_Init → DATA hunk InitTable) |
| 0x30 | `LibAlertHelper` — Alert(code) in d7, a5=0, a6 from lib+48; slides return over pushed code |
| 0x4a | `LibInit` — the init function (d0=lib, a0=seglist, a6=SysBase) |
| 0x12c | **new in 46.6**: `FindResident("MMU-SuperKickstart")` → `bset #0,lib+0x2a` on hit (30-byte insert vs 46.5) |
| 0x156 | `CacheControl(0x2101,0x2101)` in init — enable I-cache + D-cache + write-allocate (inserted in 46.5) |
| 0x1cc | init failure tail: FreeMem(neg+pos), return NULL |
| 0x20c | `PatchTable` — Disable, per record SetFunction + save old at fn-4, Enable |
| 0x24c | `SuperTT` wrapper — `Supervisor(super_tt)` with a5 saved |
| 0x262 | `super_tt` — `pmove (sp),tt0` / `pmove (sp),tt1` (TT0=0x00008514, TT1=0x00ff0125), rte |
| 0x27e | `UnpatchTable` — restores saved vectors for non-NULL slots |
| 0x2ba | `MMUCopy` — mmu -150, then mmu -282(obj,0x83e00403)/-282(obj,0x83e00405), copies 16 bytes src→dst |
| 0x306 | `P5emuExpunge` — Forbid, FindName(&LibList,"p5emu.library"), call its -24 with a1=own lib, Permit |
| 0x360 | helper: `patch_sysbase=sysbase`, `patch_lib=lib`, `PatchTable(A)` |
| 0x37a | `UnpatchTable(A)` — failure path only |
| 0x386 | `PatchTable(B)` — exec + input.device batch |
| 0x392 | `_patchbase` — the patch region (slots + stubs, see structures/layout.md) |
| 0x538 | `InstallExcVecs` — stores lib→patch_lib, `Supervisor(super_excvec)`, CacheClearU |
| 0x55a | `super_excvec` — VBR read, writes vbr[d0] AND abs[d0] from table C |

## Exec vectors used

OpenLibrary(-552), CloseLibrary(-414), SetFunction(-420), FindName(-276),
FindResident(-96, new in 46.6), Forbid(-132), Permit(-138),
Disable(-120), Enable(-126), Supervisor(-30), Alert(-108),
FreeMem(-210), CacheClearU(-636, inside stubs), CacheControl(-648,
init tail *and* inside ColdReboot).

## Patched vectors

SetFunction installs region stubs over:

- exec **-726** ColdReboot — **46.6**: pushes the old vector first,
  then `btst #0,[patch_lib]+0x2a`; when the SuperKickstart flag is set
  it skips Disable/CacheControl/Supervisor entirely and the trailing
  `rts` tail-calls the original vector.
- exec **-396** AddLibrary, **-414** CloseLibrary, **-432** AddDevice,
  **-486** AddResource, **-282** AddTask, **-168** AddIntServer,
  **-162** SetIntVector, **-372** GetMsg, **-36** (unpublished slot)
- input.device **-30** BeginIO

Each stub's first longword (fn-4) holds the replaced vector.

## Exception vectors installed (FPU present only)

VBR+0xc0..0xd8 (vectors 48-54), written to both `vbr[d0]` and the
absolute low-memory slot `abs[d0]` (`movel a2,@(0,d0:w)`); the old
vector is saved at `lib[saveoff]`:

| vbr | vec | handler | flag bit | saveoff |
|-----|-----|---------|----------|---------|
| 0xc0 | 48 | pf_trap0 (BSUN) | 0 | 0x54 |
| 0xc4 | 49 | pf_trap1 (Inexact) | 1 | 0x58 |
| 0xc8 | 50 | pf_trap2 (DivZero) | 2 | 0x5c |
| 0xcc | 51 | pf_trap3 (Underflow) | 3 | 0x60 |
| 0xd0 | 52 | pf_trap4 (OperandErr) | 6 | 0x64 |
| 0xd4 | 53 | pf_trap5 (Overflow) | 4 | 0x68 |
| 0xd8 | 54 | pf_trap6 (SignalingNaN) | 5 | 0x6c |

Flag bits live in `lib+34` (b_FPUFlags), set by FPUControl.  When the
bit is set the handler runs the fsave-frame fixup (sets bit3 of the
frame byte at `sp+d0` where d0=frame size byte) then `rte`s; otherwise
it tail-calls the saved vector by pushing it and `rts`ing.

## Third-party LVOs

- `mmu.library` **-54** `GetMMUType` → 0 means NOMMU (sets CPUFlags bit1)
- `mmu.library` **-150** → object handle (NULL → skip the -282 pair)
- `mmu.library` **-282** with ids `0x83e00403`/`0x83e00405` → two
  objects; 16 bytes copied from the first to the second
- `p5emu.library` **-24** — called with a1 = this library's base
