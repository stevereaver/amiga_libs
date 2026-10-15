---
file: log
---
# Work log

- 2026-10-15: cgxvideo 41.10 (020, BVision/CGX3) — 4-hunk
  AUTOINIT driver lib, 15 abs vectors, CYBI SetFunction patches
  into layers.library (-180/-168), KPrintF debug hunk w/
  HUNK_SYMBOL tail. Verbatim .byte emission of all 4 hunk
  bodies; fixup pools .text/.data and verifies+splices the orig
  record stream; BYTE-IDENTICAL (6280B). machine68k oracle:
  init, 2x open (all 8 deps traced incl. FindName on LibList), 2
  SetFunction patches, all 15 vectors, close/expunge —
  RUNTIME-IDENTICAL (24999273 deterministic invalids).
  md5 87eff9838f059f00cf337a22990ea7fa,
  sha256 f2d65409178190466d3ebfc6de7db9166eed04d11c8123a573a08a4e8b0b6a84.
  Sibling 040 build = same code, 1-byte $VER diff.
  Plane AMIGALIBS-???.
