# 68030.library 46.5 — RE Log

## Structural analysis

- HUNK_HEADER, 2 hunks: CODE `0x188` longs (1568 B) @file+0x24,
  DATA `0x86` longs (536 B) — code hunk grew 16 B vs 46.3, data hunk
  identical size.
- `code+0`: `moveq #-1,d0/rts` bootstrap stub; RomTag at `code+4`
  (AUTOINIT, ver 46, `rt_Init → DATA+0x00`).
- DATA hunk holds the whole AUTOINIT block: InitTable
  `{0x74, →0x10 functab, 0 datatab, →code+0x4a}`, 37-entry functab,
  strings, patch tables A/B, exception table C — same offsets as 46.3;
  only the code pointers inside are +0x10-shifted and the id string
  reads `46.5 (28.07.2018)`.

## Deltas vs 68030_46.3 (the direct predecessor)

Full byte-level diff of both hunks against the shipped 46.3 binary:

- **Single 16-byte insertion in init** at code+0x13a:
  `moveal a4@(48),a6 / movel #0x2101,d0 / movel d0,d1 / jsr a6@(-648)`
  = `CacheControl(0x2101,0x2101)` — enable I-cache (bit0), D-cache
  (bit8) and write-allocate (bit13) on both the newBits and the mask.
  Placed between the mmu -150/-282 object-copy helper and the
  p5emu-expunge helper, unconditional.
- `lib_Version/lib_Revision` written as one long `#0x2e0005` (was
  `#0x2e0003`) — revision 3→5.
- Everything else is +0x10 address-shift fallout: all branch
  displacements, PC-relative refs, functab entries and the patch
  tables' region pointer (0x366→0x376) shifted by the insert.
- The mmu-copy and p5emu-expunge helpers were already separate `bsr`
  targets in 46.3's shipped init; 46.5's CacheControl call lands
  between them.  The reconstruction mirrors this with `_CopyMMUObj` +
  `_P5EmuExpunge` (46.3's reconstruction had them merged in
  `_InitStage2`).

## 68030 family deltas vs the 68020 builds (for reference)

- CPU gate shifted one bit: require AFB_68030(bit2), reject
  AFB_68040(bit3); the 68020 build required bit1/rejected bit2.
- `super_nop` → `super_tt`: the NOMMU Supervisor body writes PMMU
  transparent-translation registers TT0=0x00008514, TT1=0x00ff0125
  via `pmove (sp),ttX` instead of running `nop;rte`.
- `super_coldreboot` gains an unconditional TT0=TT1=0x00ff8707
  setup before the NOMMU-gated `pmove tc=0` shutdown.

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
- The 68030 CPU gate needs `AttnFlags & AFF_68030` — the first
  oracle attempt passed 0x02 (AFF_68020) and hit the silent reject;
  correct flag is 0x04 (0x14 with 68881).

## Build + verification

- `source/`: 68030.c (init/lifecycle/FPUControl/PatchTable +
  the new CacheControl call), 68030_lib.s (RomTag/InitTable/functab/
  strings/tables), 68030_patch.s (helpers split into _CopyMMUObj +
  _P5EmuExpunge + patch region + handlers), Makefile (`-m68030`).
- `work/oracle.py` (adapted from the 68030_46.3 harness): happy path
  identical; 10-case matrix (040/020 CPU rejects, 030+FPU, mmutype!=0,
  no input.device, no p5emu, expansion/utility/mmu open failures,
  NULL mmu object) — all match; the new `cachecontrol` call lands in
  the exact position in the log on every path.
- ColdReboot chain verified: disable → CacheControl(0,-1) →
  Supervisor(super_coldreboot w/ TT writes + PMMU-off + ROM jump)
  → Alert(0x3f000002) → enable — identical on both binaries.

## Late correction (46.6 work)

- Operand-level diffing (the original 46.3→46.5 pass compared only
  opcodes/structure) revealed a second real delta: `super_tt`'s
  constants changed from 46.3's TT0=0x00008407 / TT1=0x00ff8107 to
  TT0=0x00008514 / TT1=0x00ff0125 — the oracle cannot see `pmove`
  writes, so this slipped the first pass. Source and docs corrected;
  super_coldreboot's 0x00ff8707 is unchanged across all versions.
