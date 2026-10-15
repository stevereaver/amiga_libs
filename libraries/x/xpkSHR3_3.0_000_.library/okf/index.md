---
bundle: xpkSHR3_3.0_000_.library
status: complete
updated: 2026-10-15
---
# xpkSHR3.library 3.0 (000)

XPK sub-library ("Shrink" compressor, Matthias Meixner,
1 Oct 2013) — **68000 build**, sibling of the 020/060
variants. Flat single CODE hunk (0x423 longs). AUTOINIT
resident@h0+4 ver 3, InitTable@h0+0x64. 10 word-offset
vectors. See `../../xpkSHR3_3.0_020_.library/okf/` for the
shared SHR3 codec semantics.

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks, 000-vs-020 deltas
