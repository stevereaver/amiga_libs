---
bundle: muihelp_19.9.library
status: complete
updated: 2026-10-15
---
# muihelp.library 19.9 (12.02.97) — Stefan Stuntz

MUI help-bubble support library (SAS/C build). 3-hunk file:
h0 CODE 0x305 longs (strings + RomTag + all code), h1 DATA
0x1df longs (SAS/C a4 segment: packed image blob + opened-lib
globals), h2 DATA|0x40000000 6 longs, body = 24 zero bytes
(chip-flagged block referenced from code at h0+0xa58).

RomTag @h0+0x56: ver 19 rev 9, NT_LIBRARY, pri 0, flags=0 —
NOT AUTOINIT. rt_Init -> h0+0xec is a real init routine that
calls exec MakeLibrary(functab@h0+0xb14, 0, 0, dSize=0x54),
fills the node, InitSemaphore(lib+0x26), opens deps lazily on
first Open (dos/graphics/intuition/utility v36, muigfx v19,
layers v36) into a4+0x764..0x778, AddLibrary.

Two user vectors: -30 create (alloc 188B obj, MUIGfx decode
packed image, render into bitmap, intuition window), -36
dispose (CloseWindow, MUIGfx frees, FreeVec).

- `structures/layout.md` — hunk map, RomTag, data segment
- `functions/vectors.md` — LVO table + init/open/close
- `findings/defects.md` — quirks (flagged zero DATA hunk,
  relocated-0 reserved vector, IdString offset)
