# config.library 1.0

`config.library` — 'config 1.0 (12.10.96)' by Adam Dawes. An
INI-style config file library: reads `[section]` + `key = value`
files, provides get/set of string and numeric keys by rewriting the
file.

- 2956 bytes, MD5 `3251b43caed885d8c0ba93b8ac1c3d1e`
- Two hunks: HUNK_CODE 2404B + HUNK_DATA 0x154B (file body;
  header allocates 0x56 longs — one more than the body, quirk
  preserved by fixup.py)
- AUTOINIT, RomTag lives in the DATA hunk (h1+0xa4);
  InitTable at h1+0x118, datatab at h1+0xbe, functab at h1+0x128
- **Version quirk**: RomTag/datatab say version 3.0 while the
  idstring is `config 1.0` — version field and marketing version
  disagree
- SAS/C with small-data model: `a4 = _h1+0x7ffe`, globals at
  `a4@(-32690)` = _h1+0x4c etc.
- RELOC32 groups in scrambled (non-ascending) producer order
- Deps: dos/intuition/graphics v37 opened at init into
  _h1+0x50/0x54/0x58; execbase+seglist in lib privdata +0x26/+0x22

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
