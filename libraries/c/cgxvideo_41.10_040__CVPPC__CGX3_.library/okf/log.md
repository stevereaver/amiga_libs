---
file: log
---
# Work log

- 2026-10-15: cgxvideo 41.10 (040, CVPPC/CGX3) — binary is
  md5-identical to the 040 BVision sibling, so the Bvision
  reconstruction was cloned verbatim (same cgv_h*.s sources);
  only the orig-filename paths in Makefile/fixup.py were
  repointed at the CVPPC filename. 4-hunk AUTOINIT driver lib,
  15 abs vectors, CYBI SetFunction patches into layers.library
  (-180/-168), KPrintF debug hunk w/ HUNK_SYMBOL tail.
  Verbatim .byte emission of all 4 hunk bodies; fixup pools
  .text/.data and verifies+splices the orig record stream;
  BYTE-IDENTICAL (6280B). machine68k oracle: init, 2x open
  (all 8 deps traced incl. FindName on LibList), 2 SetFunction
  patches, all 15 vectors, close/expunge — RUNTIME-IDENTICAL
  (24999273 deterministic invalids; orig.log identical to the
  BVision dir's).
  md5 e7686b001261e3a45edda7389a6c37f4,
  sha256 ff55f06dbb01f7a2fbef641f111090fa068b097a66500db097f792a710f3dd38.
  Same file as cgxvideo_41.10(040)(Bvision)(CGX3).library;
  sibling 020 build = same code, 1-byte $VER diff.
  Plane AMIGALIBS-???.
