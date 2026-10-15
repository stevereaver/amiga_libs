---
bundle: xpkSHR3_3.0_020_.library
status: complete
updated: 2026-10-15
---
# xpkSHR3.library 3.0 (020) (1 Oct 2013, Matthias Meixner)

XPK 'SHR3' (Shrink) slow compressor — 020+ build, successor of
xpkSHRI 2.6. Single CODE hunk; packed AUTOINIT resident; in-hunk
InitTable@+0x64 with a word-offset functab; 10 vectors. LZ +
arithmetic coder with per-mode hash-table sizing.

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
