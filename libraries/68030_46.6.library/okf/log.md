# 68030.library 46.6 — RE Log

## Structural analysis

- HUNK_HEADER, 2 hunks: CODE `0x193` longs (1612 B), DATA `0x8a` longs
  (552 B) — code grew 44 B and data grew 16 B vs 46.5.
- `code+0`: `moveq #-1,d0/rts` bootstrap stub; RomTag at `code+4`
  (AUTOINIT, ver 46, `rt_Init → DATA+0x00`).
- DATA hunk holds the whole AUTOINIT block: InitTable
  `{0x74, →0x10 functab, 0 datatab, →code+0x4a}`, 37-entry functab,
  strings, patch tables A/B, exception table C.  New string
  `"MMU-SuperKickstart"` at DATA+0x189 (16 bytes incl. NUL + pad);
  patch tables A/B shifted 0x18c→0x19c / 0x198→0x1a8, exception
  table 0x1dc→0x1ec, patch-region pointer 0x376→0x392.

## Deltas vs 68030_46.5 (the direct predecessor)

Full operand-level byte diff of both hunks against shipped 46.5:

- **28-byte init insertion** (~code+0xea, inside the init tail):
  `moveal a4@(48),a6 / lea pc@(skname),a1 / jsr a6@(-96) /
  tstl d0 / beq / bset #0,lib+0x2a` — `FindResident(
  "MMU-SuperKickstart")` sets bit0 of the previously-unused flag byte
  at lib+0x2a.  Lands between the patch-table SetFunction batch and
  the SuperTT/MMU-copy tail.
- **16-byte ColdReboot insertion**: `pf_coldreboot` now begins
  `movel [slot],sp@-` (push the replaced vector — needed as the
  return target) then `moveal [patch_lib],a5 / btst #0,a5@(0x2a) /
  bne` to the trailing `rts`.  Flag set → bare tail-call into the
  original ColdReboot; flag clear → the 46.5 sequence unchanged.
- `lib_Version/lib_Revision` written as one long `#0x2e0006` (was
  `#0x2e0005`) — revision 5→6.
- New DATA-hunk string `"MMU-SuperKickstart"` at +0x189.
- Everything else is +0x1c/+0x2c address-shift fallout (all code
  pointers shift +0x1c up to the ColdReboot insert and +0x2c after
  it; data-hunk objects after 0x189 shift +0x10; patch-region-internal
  `fnoff` fields shift +0x10 since the region grew at its head).
- super_tt constants are the **46.5** values TT0=0x00008514 /
  TT1=0x00ff0125 (unchanged in 46.6 — verified by operand diff; the
  46.3→46.5 constant change was caught late and fixed in the 46.5
  reconstruction as well).
- super_coldreboot's TT0=TT1=0x00ff8707 is identical across
  46.3/46.5/46.6.

## 68030 family deltas vs the 68020 builds (for reference)

- CPU gate shifted one bit: require AFB_68030(bit2), reject
  AFB_68040(bit3); the 68020 build required bit1/rejected bit2.
- `super_nop` → `super_tt`: the NOMMU Supervisor body writes PMMU
  transparent-translation registers via `pmove (sp),ttX` instead of
  running `nop;rte`.
- `super_coldreboot` gains an unconditional TT0=TT1=0x00ff8707
  setup before the NOMMU-gated `pmove tc=0` shutdown.

## Notable decodes

- `2f3b/083b` handler encodings = memory-indirect PC operands:
  `[patch_lib]` gives the lib base; the outer displacement selects
  the flag byte (0x2a for the SK gate, 0x22 for the FPU handlers) or
  the saved-vector slot.
- `218a 0190` in super_excvec = absolute-indexed `move.l a2,(d0)`:
  the handlers are mirrored into the raw vector-table bytes at
  $c0..$d8 as well as `vbr[d0]` (verified empirically under
  machine68k).
- Alert set: 0x3f000001 (dead vectors), 0x3f000002 (ColdReboot
  failure), 0x3f02800a (expansion), 0x3f02800c (utility),
  0x3f028021 (input.device), 0x3f02803e (mmu.library); dead block
  pushes 0x3f028005.
- The 68030 CPU gate needs `AttnFlags & AFF_68030` — pass 0x04
  (0x14 with 68881) to the oracle.

## Build + verification

- `source/`: 68030.c (init/lifecycle/FPUControl/PatchTable +
  FindResident gate + the 46.5 CacheControl call), 68030_lib.s
  (RomTag/InitTable/functab/strings incl. `_skname`/tables),
  68030_patch.s (helpers split into _CopyMMUObj + _P5EmuExpunge +
  patch region + handlers), Makefile (`-m68030`).
- `work/oracle.py` (adapted from the 46.5 harness): adds a
  FindResident trap with an `skmod` switch and a patched-vector
  ColdReboot exercise.  Happy path identical; 10-case matrix
  (040/020 CPU rejects, 030+FPU, mmutype!=0, no input.device, no
  p5emu, expansion/utility/mmu open failures, NULL mmu object) — all
  match.
- ColdReboot verified in both modes: skmod=0 → disable →
  CacheControl(0,-1) → Supervisor(super_coldreboot) →
  Alert(0x3f000002) → enable; skmod=1 → `skflags=01` at lib+0x2a and
  the patch tail-calls the original vector with no other calls.
  Identical on both binaries.
- TT constants verified by byte comparison against the shipped image
  (pmove register writes are invisible to the call log).
