---
bundle: muirexx_19.9.library
status: complete
updated: 2026-10-15
---
# muirexx.library 19.9 (12.02.97)

Single-CODE-hunk library by Stefan Stuntz (MUI ARexx support):
h0 CODE 0x4d0 longs = 0x1340B holding everything (reserved stub,
name/idstring, RomTag @+0x56, builtin command tables @0x70..0x1f0,
strings, all code from +0x374, functab @+0xe40), h1 BSS 5 longs.
RomTag flags=0x00 (NOT autoinit): rt_init -> real code @h0+0x374
which self-registers via exec MakeLibrary (13 abs-long vectors,
dSize 0x54) + AddLibrary. Deps opened lazily on first Open:
dos/utility/intuition v36 + muilowlevel v19 into BSS+4..+0x10.
rexxsyslib.library is opened on demand inside vectors -60/-78.

- `structures/layout.md` — hunk map, RomTag, command tables, BSS
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks (non-AUTOINIT init, relocated-0 -24)
