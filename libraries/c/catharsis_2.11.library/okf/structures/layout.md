---
file: layout
---
# catharsis 2.11 layout

File 5124B. Header 0x3f3, no names, tablesize 3, hunks 0..2,
sizes 0x440 / 0x32 / 0x4 longs.

- h0 CODE 0x440 longs = 4352B @0x28..0x1128. RELOC32 tails:
  6->h0 (e72 e76 f98 f00 f6e fb4 — RomTag self ptrs + 4 code
  refs), 7->h1 (e86 e82 e7e = rt_init/idstring/name; ec8 eea
  103e 106c = code refs to h1 strings), 74->h2 (BSS globals).
  END @0x12a4.
- h1 DATA 0x32 longs = 200B @0x12b0..0x1378. RELOC32: 24->h0
  (all 23 functab slots + initfn slot @0xc4), 1->h1 (ftab ptr
  @0xbc). END @0x13f4.
- h2 BSS 4 longs = 16B, no body, END @0x1400.

## h1 DATA map

| off | content |
|-----|---------|
| 0x00 | "graphics.library" |
| 0x14 | "intuition.library" |
| 0x28 | "catharsis.library" (rt_name target) |
| 0x3c | "catharsis 2.11 (27-Apr-03)" (rt_idstring) |
| 0x58 | functab: 23 abs-longs ->h0, 0xffffffff term @0xb4 |
| 0xb8 | InitTable: dsize=0x866, ftab->h1+0x58, dtab=0, initfn->h0+0xe8c |

## RomTag @h0+0xe70 (standard 26B)

4afc, matchtag->self, endskip->h0+0xe8a (self+0x1a),
flags 0x80 AUTOINIT, ver 2, type 9 (NT_LIBRARY), pri 0,
name->h1+0x28, id->h1+0x3c, init->h1+0xb8.

## h2 BSS (16B), filled by initfn @h0+0xe8c

- +0x0 execbase (movel a6 -> BSS+0)
- +0x4 GfxBase (OpenLibrary("graphics.library",33))
- +0x8 IntuitionBase (OpenLibrary("intuition.library",33))
- +0xc libbase (movel d0 -> BSS+0xc)

Code references globals via absolute-mode longs relocated
against h2 (e.g. `moveal (BSS+4).l,a6` before GfxBase calls).

## Library data area (dsize 0x866)

- +0x22 private open-count word (not the std OpenCnt@0x20)
- +0x24 seglist (stored by initfn from a0)
- +0x30 GfxBase mirror, +0x34 IntuitionBase mirror
- +0x2c execbase (init-reentry guard: init returns early if
  lib+0x2c == a6 already)
- +0x38.. +0x438 two parallel 256-entry pointer arrays
  (resource table swept by fn @h0+0x91c)
- +0x838 semaphore (NewList'ed by initfn, Obtain/Release around
  table ops: exec -564/-570)
