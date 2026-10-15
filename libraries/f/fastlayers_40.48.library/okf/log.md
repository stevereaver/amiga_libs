# fastlayers_40.48.library — reconstruction log

## Binary

1,460 bytes, 3 hunks: CODE 0xa4 lw (0x290), CODE 0x99 lw
(0x264), CODE 0x0b lw (0x2c).  RELRELOC32 tables: 15 self-refs
in hunk0 (RomTag/InitTable/functab/datatab/global), 5 hunk1
refs from the patch-table `new` fields, hunk1->hunk0 refs for
`_flbase` and the saved-original slots, hunk1->hunk2 ref for
the rect-overlap helper.

## Decode path

IRA dump (`work/fastlayers_40.48.asm`, 550 lines) was usable for
the code skeleton but mis-disassembled the string area,
functable and patch table.  Real decode done with
`m68k-amigaos-objdump -D` on the extracted hunks plus the
HUNK_RELRELOC32 lists.

Key findings:

- functable is **LONG addresses**: {Open, Close, Expunge,
  Expunge} — the reserved vector shares the stub.
- hunk0 0x114 = LibInit: opens layers/gfx/utility v39,
  FindResident(layers), AllocVec module copy, Forbid, scans
  the resident for `jmp pc@(d16)` (0x4eba) landing on the
  vector -126 target (SwapBitsRastPortClipRect) and rewrites
  them in the copy as `jsr a6@(-126)` (0x4eae 0xff82), walks
  layers' functab re-pointing vectors at the copy, then the
  five-entry {lvo,new,saved} patch loop, CacheClearU, Permit.
- hunk0 0x22a = patch table; 0x26a/0x278/0x28c =
  Open/Close/Expunge stubs.
- hunk1 = the five patched routines; hunk2 = word-compare
  rect-overlap helper.

## Decode details

- `a2 = layers@-124` reads the address field of the -126
  vector slot (slots are `4ef9 addr` jumps at lib-N).
- datatab sets `ln_Pri = 0xb0` (-80) — odd, reproduced.
- new CUHL: `d4 & 0x44` (SUPER|BACKDROP) -> saved original;
  else forced-SIMPLE `CreateBehindHookLayer` + `UpfrontLayer`,
  BackFill=(Hook*)1, ClearRegion(DamageList), `& ~0x680`.
- new MoveSizeLayer: `(Flags&7)==2` (SMART) -> fast path with
  occlusion/overlap scan and temporary LAYERSIMPLE remap;
  everything else -> saved original.
- all-zero delta returns `moveq #1,d4` reached via a branch
  into the middle of a `cmpiw` — reproduced as `return 1`.

## Reconstruction

- `fastlayers_lib.s`: packed RomTag (26 bytes), strings,
  `_flbase` global, InitTable dataSize 0x3c, LONG functab,
  byte-exact datatab, five-entry `_patchtab`.
- `fastlayers.c`: LibInit (resident copy + rewrite + double
  SetFunction pass), the stubs, and the five routines with
  register-bound params (a0/a1/d0-d4/a2/a3/a6) matching the
  layers vector ABI.  Saved-original calls go through a5/a1
  `jsr` macros like the original.
- Compiled code verified against the disassembly — LibInit
  produces the same instruction sequence incl. the
  `{0x4eae,0xff82}` copy rewrite and the `a2@(0,d5:l)` LVO
  index trick GCC independently generated.

## Verification

- Builds clean with `m68k-amigaos-gcc -O2 -m68000`.
- dataSize 0x3c, datatab byte-identical, LONG functab with the
  reserved vector sharing Expunge.
- LVO call inventory identical: exec -96/-132/-138/-420/-552/
  -624/-636/-684, layers -48/-120/-138/-192, gfx -528.
- DoHookClipRects eliminated as dead (sentinel always 1) —
  same effective reachability as the original.
- One-hunk build instead of three (relocatable layout
  difference only).
