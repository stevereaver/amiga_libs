# fastlayers.library 40.48

A. Kneer / T. Abt, 16.03.98.  1,460-byte AUTOINIT library,
three hunks (all code: 0x290 + 0x264 + 0x2c).

**"FastLayers"** — a layers.library accelerator/patcher.  The
library itself exports no public API (functable = Open, Close,
Expunge-stub, Expunge-stub); all work happens inside `LibInit`:

1. opens `layers.library`, `graphics.library`, `utility.library`
   (all v39+)
2. `FindResident()`s the layers module and `AllocVec`s a RAM copy
3. rewrites internal `jmp pc@(d16)` tail-calls to
   `SwapBitsRastPortClipRect` (-126) into `jsr a6@(-126)` so the
   copy calls back through the vector
4. re-points every layers vector still targeting the ROM at the
   relocated copy (`SetFunction`)
5. installs five hand-written replacements:

| LVO  | function                  | new behaviour |
|------|---------------------------|---------------|
| -186 | CreateUpfrontHookLayer    | cheap non-super/backdrop create: forced-LAYERSIMPLE `CreateBehindHookLayer` + `UpfrontLayer`, damage region cleared, `BackFill=(Hook*)1` |
| -36  | CreateUpfrontLayer        | wrapper -> new CUHL with hook=0 |
| -60  | MoveLayer                 | wrapper -> new MoveSizeLayer(l,dx,dy,0,0) |
| -180 | MoveSizeLayer             | SMART layers: if unoccluded and overlapping no front layer, temporarily remapped to LAYERSIMPLE so the original routine takes the fast blit path |
| -66  | SizeLayer                 | wrapper -> new MoveSizeLayer(l,0,0,dw,dh) |

6. `CacheClearU`, `Permit`, return the library base

The effect: simple/smart layers stop paying for cliprect
rebuilds on creation and move/size — the classic 1998-era
"layers in fast RAM + fast layer ops" accelerator.

Expunge is a no-op (`return 0`): once installed the patches are
permanent until reboot.

## Files

- `source/fastlayers_lib.s` — RomTag, strings, InitTable
  (dataSize 0x3c, LONG functab), exact InitStruct DATATABLE,
  the `_flbase` global slot and the five-entry `_patchtab`.
- `source/fastlayers.c` — LibInit + vectors + the five patched
  routines (single hunk; original used three).
- `source/Makefile`
- `work/fastlayers_40.48.asm` — IRA disassembly (partially
  garbled on the string/patch-table regions; objdump output was
  used for the real decode).

## Library base (dataSize 0x3c)

| off | field |
|-----|-------|
| +34 | private DELEXP-style flag byte (never set — dead) |
| +36 | ExecBase |
| +40 | GfxBase |
| +44 | UtilityBase |
| +48 | LayersBase |
| +52 | seglist |
| +56 | AllocVec'd layers-module copy |

## Global slots in code hunk

- `flbase` (orig hunk0+0xc8) — the fastlayers library base, set
  by LibInit; the patched routines read `flbase->fl_Gfx` for
  `ClearRegion`.
- `patchtab` (orig hunk0+0x22a) — five `{lvo,new,saved}` LONG
  triples + `-1` terminator; `.saved` filled by SetFunction and
  used to call the original routines back.
