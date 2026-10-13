# Pony3D.library 1.0(000) — OKF index

Tomasz "Pony van Deathface" Pęczek's tiny **3D vertex-math
library** (ASM-One 1.25, 13-Feb-2000): fixed-point rotate /
translate / perspective-project on int16 vertex lists, plus a
40-byte-pitch bitplane plotter.  68000 build — (020), (FPU)
and (060FPU) siblings exist, all pending.

The image doubles as a CLI command: running it opens
reqtools.library v38 and shows a credits requester with an
"OKAY" gadget (falls back to `Write(Output(), idstr)` via
dos.library), then returns `RETURN_ERROR` (20).

- Binary: `binary/Pony3D_1.0(000).library` — 2348 bytes, m68000.
- Reconstruction: `source/` — C API (`pony3d.c`) + AutoInit
  glue/CLI bootstrap (`pony3d_lib.s`).

## Hunk layout (original)

Two hunks: `CODE 0x3a8` (CLI bootstrap @+0, RomTag @+0xc6,
name/id strings, InitTable @+0x16e, lifecycle, 4 API fns) +
`DATA 0x4cc` ("dos.library"/"reqtools.library"/"Pony3D.library"
name strings, credits text, "OKAY" gadget, 512-word trig
table @+0xa6).  20 hunk0 self-relocations + 7 code→hunk1.

RomTag: AUTOINIT(0x80), version 1, NT_LIBRARY, pri 0.
InitTable: dataSize=0x2a, functab@+0x17e (8 absolute longs +
-1), datatab@+0x1a2 (8-bit-offset InitStruct forms, includes
a dead `byte@12=9` write clobbered by ln_Name), init@+0x1c2.

## Vectors (8)

| LVO | Target  | Function                                  |
|-----|---------|-------------------------------------------|
| -6  | +0x1d8  | LibOpen (opencnt++, clear DELEXP bit3@14) |
| -12 | +0x1e6  | LibClose (deferred expunge)               |
| -18 | +0x1fa  | LibExpunge (correct)                      |
| -24 | +0x240  | null stub (`moveq #0,d0;rts`)             |
| -30 | +0x244  | RotatePoints(src:a0,dst:a1,ax:d4,ay:d5,az:d6) |
| -36 | +0x306  | TranslatePoints(src:a0,dst:a1,dx:d0,dy:d1,dz:d2) |
| -42 | +0x32a  | ProjectPoints(src:a0,dst:a1,f:d0,cx:d1,cy:d2)  |
| -48 | +0x384  | Plot(list:a0, plane:a1)                   |

All lists are `[count][elements]` where count is a `dbf`
counter — **count+1 elements are processed** (last-index
convention).  Rotate uses a 512-word trig table in the DATA
hunk: sin = `tab[a/2]`, cos = `tab[256+a/2]` (byte-offset
indexing, angles in 2-unit steps mod 512, +2 bias at entry).
Project: `sx = cx + x*f/z`, `sy = cy + y*f/z`, z==0→+1 —
with cx/cy **halved inside the loop** (see defects).
Plot: `plane[y*40 + x/8] |= 1 << ((~x)&7)` (MSB-first).

## Verification status

machine68k oracle (`work/oracle.py`): **byte-identical**
across the full battery — library header (incl. ln_Type=0
quirk), lifecycle + deferred expunge, all 4 API functions on
directed cases + 120-case randomized differential sweep
(rotate/translate/project/plot + 2KB plane bit patterns),
CLI bootstrap reqtools-requester sequence (identical vector
calls, request object init, title string), and the
dos-fallback path (identical Write of the 119-byte idstr).

## Files

- `functions/vectors.md` — vector/LVO details + ABI + quirks
- `functions/codec.md` — trig table format, fixed-point math,
  CLI bootstrap sequence
- `structures/layout.md` — hunk map, data area, InitTable
- `findings/defects.md` — shipped quirks and bugs reproduced
- `log.md` — work log
