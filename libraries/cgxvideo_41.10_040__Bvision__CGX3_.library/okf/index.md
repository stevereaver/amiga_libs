---
bundle: cgxvideo_41.10_040__Bvision__CGX3_.library
status: complete
updated: 2026-10-15
---
# cgxvideo.library 41.10 (6.10.97) 68040 — CGX3 BVision driver

phase5 digital products CyberGraphX-3 video driver for the
BVision card ("written by F.Mariak", (c) 1996-1998). 6280B,
"68040" per the $VER string (see below — the code itself is
identical to the 020 build).

- 4-hunk HUNK file: h0 CODE 0x88 longs (resident + InitTable +
  functab + 6 'CYBI' patch descriptors/stubs), h1 DATA 9 longs
  ("OverlaySemaphore" + layers.library patch table), h2 CODE
  0x4a0 longs (initfn + Open/Close/Expunge + 8 driver funcs),
  h3 CODE 0x20 longs (KPrintF-style serial-debug stub with a
  HUNK_SYMBOL tail, 29 symbols: KPutCh/KPutStr/KPutFmt/KGetChar/
  KMayGetChar/KDoFmt/KPrintF + underscored aliases, ps0/ps1).
- Resident @h0+4 (standard 26B): flags 0x80 AUTOINIT, ver 41,
  type 9, pri 0; name->h0+0x1e, id->h0+0x30, init->h0+0xc8,
  EndSkip->h2+0x1280 (top of hunk 2 — resident spans h0..h2).
- InitTable @h0+0xc8: dsize 0xbc, ftab->h0+0xd8 (15 abs-long
  vectors, -1 term), dtab->h0+0x118, initfn->h2+0xea.
- Sibling of `cgxvideo_41.10_020__Bvision__CGX3_.library`: the
  two binaries differ by exactly ONE byte (file 0xab): '4' vs
  '2' in the $VER string ("68040 Version" vs "68020 Version").
  All code, data and relocation records are byte-identical —
  the "020/040" builds are the same object code with a
  different CPU-name string. Same reconstruction sources serve
  both; only the emitted hunk0 byte at +0x7f differs.

- `structures/layout.md` — hunk map, resident, InitTable,
  CYBI descriptors, lib/object fields
- `functions/vectors.md` — LVO table + deps
- `findings/defects.md` — quirks/dead code
