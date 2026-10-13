# 68030.library 46.3 — Structures / Layout

## Private library base (dataSize = 0x74)

Same layout as `68020_46.3` — the InitTable dataSize is 0x74 and the
init function fills every field by hand (datatab is NULL).

| off | field | contents |
|-----|-------|----------|
| 0x00 | Library node | filled by init: ln_Type=9, ln_Name→"68030.library", lib_Flags=6, lib_Version=46, lib_Revision=3, lib_IdString→idstr |
| 0x22 | b_FPUFlags | FPUControl flag byte (aliases the high byte of lib_Revision) |
| 0x24 | b_Magic | `'THOR'` signature |
| 0x2b | b_CPUFlags | bit0: no 68881/882 present; bit1: GetMMUType()==0 (no PMMU) |
| 0x2c | b_SegList | seglist (a0) from LibInit |
| 0x30 | b_SysBase | ExecBase |
| 0x34 | b_Utility | utility.library v37 |
| 0x38 | b_Expansion | expansion.library v37 |
| 0x44 | b_MMU | mmu.library v0 |
| 0x48 | b_Input | input.device node (FindName on DeviceList) |
| 0x50 | pad | unused |
| 0x54..0x6c | b_TrapSave[7] | saved 68881 exception vectors (VBR+0xc0..0xd8) |
| 0x70 | pad | unused |

## RomTag (code+0x04)

`4afc / rt_MatchTag→self / rt_EndSkip=0 / RTF_AUTOINIT(0x80) /
ver 46 / NT_LIBRARY(9) / pri 0 / name→DATA+0xa8 / id→DATA+0x135 /
init→DATA+0x00`.

Preceded by the 4-byte `moveq #-1,d0/rts` bootstrap stub at code+0.

## DATA hunk layout

| off | contents |
|-----|----------|
| 0x000 | InitTable: `{0x74, →0x10 functab, 0 datatab, →code initfn}` |
| 0x010 | function table: 37 longs + `ffffffff` terminator |
| 0x0a8 | `"68030.library"` |
| 0x0b6 | `"mmu.library"` |
| 0x0c2 | `"utility.library"` |
| 0x0d2 | `"expansion.library"` |
| 0x0e4 | `"mathieeedoubbas.library"` (dead) |
| 0x0fc | `"mathieeesingbas.library"` (dead) |
| 0x114 | `"input.device"` |
| 0x121 | `"p5emu.library"` |
| 0x12f | `"$VER: "` prefix |
| 0x135 | id string (ends `0a 0d 00`) |
| 0x18c | patch table A: `{→region, {0x30,-726,0x04}, 0}` — ColdReboot |
| 0x198 | patch table B: `{→region, 10×{liboff,vecoff,fnoff}, 0}` |
| 0x1dc | exception table: `7×{newfn.l, vbroff.w, saveoff.w}, 0` |

## Patch record format

`{LONG region; {liboff.w, vecoff.w, fnoff.w}...; 0x0000}`

- `liboff` indexes a library-base slot in the private base
  (`0x30` = SysBase, `0x48` = input.device node).
- `vecoff` is the signed LVO offset (e.g. `0xfd2a` = -726).
- `fnoff` is the stub offset inside `region` (= code+0x366 shipped;
  `_patchbase` in the reconstruction).
- PatchTable stores the old vector at `fn-4` (the slot before each
  stub).  When the target lib slot is NULL it writes 0 at `fn`
  (quirk — see defects).

## Patch region layout (offsets from `_patchbase`)

| off | contents |
|-----|----------|
| 0x000 | slot: old ColdReboot |
| 0x004 | pf_coldreboot — Disable, CacheControl(0,-1), Supervisor(super_coldreboot), Alert(0x3f000002), Enable |
| 0x032 | super_coldreboot — sr=0x2700, TT0=TT1=0x00ff8707, [NOMMU? TC=0], CACR=0, VBR=0, ROM reset jump w/ 2MB gate |
| 0x098..0x0f4 | slots + pattern-A trampolines: AddLibrary(+0x9c), CloseLibrary(+0xae), AddDevice(+0xc0), AddResource(+0xd2), AddTask(+0xe4) — push old, push a1, CacheClearU, pop a1, rts→old |
| 0x0f2 | slot + pf_addintserver(+0xf6) — moveml d0/a1 variant |
| 0x108 | slot + pf_getmsg(+0x10c) — INTENA-based GetMsg |
| 0x144 | slot + pf_lvo36(+0x148) — push old, `tstw $dff01e`, rts |
| 0x154 | slot + pf_setintvector(+0x158) — moveml d0/a1 variant |
| 0x16a | patch_sysbase slot (ExecBase) |
| 0x16e | unused pad slot |
| 0x172 | slot: old input BeginIO |
| 0x176 | pf_beginio — push old; if io_Command==9: save a1/a6, a6=patch_sysbase, CacheClearU; rts→old |
| 0x194 | dead pad word |
| 0x196 | InstallExcVecs — lib→patch_lib, Supervisor(super_excvec), CacheClearU |
| 0x1b8 | super_excvec — sr=0x2700, `movec vbr,a0`, loop over table C: `lib[d1]=vbr[d0]; vbr[d0]=new; abs[d0]=new` (`218a 0190` = write to absolute d0) |
| 0x1e2 | patch_lib slot (this library's base) |
| 0x1e6..0x28c | the 7 FPU handlers (btst on flag byte via `[patch_lib]+0x22`, chain to `[patch_lib]+saveoff`, else bra pf_fsavefix) |
| 0x28e | pf_fsavefix — `fsave`, mark frame byte, `frestore`, rte |

## CPU gate

`AttnFlags` byte at ExecBase+0x129: `btst #3` (AFB_68040) → reject;
`btst #2` (AFB_68030) → require; `btst #4` (AFB_68881) clear →
CPUFlags bit0 (skip the FPU exception install later).
