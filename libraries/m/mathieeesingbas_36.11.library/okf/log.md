---
file: log
---
# Work log

- 2026-10-15: single code hunk + 2 empty hunks; objdump mis-split
  the boundary at 0x76 (`movel a0,$1f2` ext words grouped into a
  prior data line) — head data span extended to 0x78.
  Verbatim transcription + fixup resplicing 9 RELOC32 groups and
  preserving the empty hunks. BYTE-IDENTICAL.
- machine68k oracle (non-AUTOINIT MakeLibrary/AddLibrary path,
  word-offset functab support): init trace (OpenResource
  MathIEEE.resource + MakeLibrary 16 vecs + AddLibrary), all 16
  vectors, 240 invalid accesses, expunge. RUNTIME-IDENTICAL.
  Plane AMIGALIBS-292.
