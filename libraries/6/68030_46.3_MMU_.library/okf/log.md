# 68030.library 46.3 — RE Log

## Structural analysis

- HUNK_HEADER, 2 hunks: CODE `0x184` longs (1552 B) @file+0x24,
  DATA `0x86` longs (536 B).  Code relocs: 17 entries (hunk0→code
  slot stores + hunk1→table/string pointers).  Data relocs: 37
  functab pointers + 2 region pointers + 7 excvec pointers.
- `code+0`: `moveq #-1,d0/rts` bootstrap stub; RomTag at `code+4`
  (AUTOINIT, ver 46, `rt_Init → DATA+0x00`).
- DATA hunk holds the whole AUTOINIT block: InitTable
  `{0x74, →0x10, 0, →code+0x4a}`, 37-entry functab, strings,
  patch tables A/B, exception table C.
- Same THOR MMULib 46.3 family as `68020_46.3` — same private base
  (0x74), `'THOR'` magic at +0x24, CPUFlags at +0x2b, TrapSave at
  +0x54..0x6c, identical patch-table format and vector set.

## 68030 deltas vs 68020_46.3

- CPU gate shifted one bit: require AFB_68030(bit2), reject
  AFB_68040(bit3); the 68020 build required bit1/rejected bit2.
- `super_nop` → `super_tt`: the NOMMU Supervisor body writes PMMU
  transparent-translation registers TT0=0x00008407, TT1=0x00ff8107
  via `pmove (sp),ttX` instead of running `nop;rte`.
- `super_coldreboot` gains an unconditional TT0=TT1=0x00ff8707
  setup before the NOMMU-gated `pmove tc=0` shutdown.
- Region layout shifts (+0x14): super_coldreboot grew from 0x52 to
  0x66 bytes; the stub fn offsets are 0x9c/0xae/0xc0/0xd2/0xe4/
  0xf6/0x158/0x10c/0x148/0x176 (vs the 68020's 0x8c/0x9e/...).
- The mmu-copy and p5emu-expunge helpers are separate `bsr` calls
  in the shipped init (the 68020 keeps them inside InitStage2;
  the reconstruction mirrors the shipped split with _SuperTT +
  _InitStage2).

## Notable decodes

- `2f3b/083b` handler encodings = memory-indirect PC operands:
  `[patch_lib]` gives the lib base; the outer displacement selects
  the flag byte (0x22) or the saved-vector slot.
- `218a 0190` in super_excvec = absolute-indexed `move.l a2,(d0)`:
  the handlers are mirrored into the raw vector-table bytes at
  $c0..$d8 as well as `vbr[d0]` (verified empirically under
  machine68k).
- Alert set: 0x3f000001 (dead vectors), 0x3f000002 (ColdReboot
  failure), 0x3f02800a (expansion), 0x3f02800c (utility),
  0x3f028021 (input.device), 0x3f02803e (mmu.library); dead block
  pushes 0x3f028005.

## Build + verification

- `source/`: 68030.c (init/lifecycle/FPUControl/PatchTable),
  68030_lib.s (RomTag/InitTable/functab/strings/tables),
  68030_patch.s (helpers + patch region + handlers), Makefile
  (`-m68030` for pmove/movec/fline).
- `work/oracle.py` (adapted from the 68020_46.3 harness, CPU
  bumped to M68030): happy path identical; 12-case matrix
  (FPU/NOMMU combos, 040/020/000 rejects, every OpenLibrary and
  FindName failure, missing p5emu, NULL mmu object) all match.
- VBR install verified post-init: vectors 48-54 point at the 7
  handlers; TrapSave holds the prior contents; no-FPU build
  leaves the table untouched.
- ColdReboot chain verified: disable → CacheControl(0,-1) →
  Supervisor(super_coldreboot w/ TT writes + PMMU-off + ROM jump)
  → Alert(0x3f000002) → enable — identical on both binaries.
