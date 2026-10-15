---
file: log
---
# Work log

- 2026-10-15: single CODE hunk, verbatim transcription (raw head
  0..0xac incl. resident/strings/InitTable/word functab). fixup.py
  splices the 21-slot RELOC32 tail. BYTE-IDENTICAL.
- machine68k oracle (adapted from xpkLIN2): init + open x2 +
  expunge/close-underflow + PackerInfo mode table + 19 pack buffers
  round-tripped via Pack/Unpack + mode30/60/100 + passworded
  pack/unpack (good+bad pw) + PackFree/UnpackFree + alloc-edge.
  RUNTIME-IDENTICAL; all packed streams byte-identical.
  Plane AMIGALIBS-284.
