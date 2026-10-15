---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-15
- Upgraded to byte-identical verbatim asm (`mdb040_v.s`) via the
  shared tools/transcribe.py pipeline; single literal-vs-decimal
  fix ("36" disp -> 0x24 in a "40.6" string byte) then fixup.py
  splices the 26-entry ascending RELOC32 tail.
- oracle.py adapted from the FPU sibling for the two-stage gate:
  AFF_68040 (bit3) always required; AFF_FPU40 (bit6) only when
  exec lib_Version>=39. 8-case matrix + all vectors identical.
- Corrected index.md: the vector region is NOT byte-identical to
  the FPU build (idstring +4 shifts all targets; gate extended).


## 2026-10-10
- Parsed 900-byte single-CODE-hunk module: same Berndt
  framework as mathieeedoubbas 40.6 FPU — absolute-longword
  functab, dataSize 0x2c, private DELEXP byte at +0x2a.
- Code region is byte-identical to the 68881/82 build: same
  faddd/fsubd/fmuld/fdivd, same fintrz/fint Floor paths, same
  integer Cmp/Tst/Abs/Neg.  Only idstring differs
  ("for 68040") plus table offsets and the init gate.
- Init gate decoded: btst #3 (AFF_68040) required; cmpi.w
  #0x27,lib_Version — under exec v39+ also btst #6 (AFF_FPU40),
  older exec passes on 68040 alone.
- Reconstructed: shared math.s + adapted LibInit; builds.
- 040-build quirks filed with the FPU-build card family
  (AMIGALIBS-22 covers the private-DELEXP deviation pattern).
