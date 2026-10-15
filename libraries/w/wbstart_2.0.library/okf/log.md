---
file: log
---
# Work log

- 2026-10-15: COLDSTART wbstart 2.0. Raw `.byte` verbatim
  emission (h0 .text / h1 .data), wbstart_2.2 fixup resplits
  and splices original RELOC32 tails + DATA alloc/body quirk.
  BYTE-IDENTICAL.
- machine68k oracle reused from 2.2 (same functab/vector
  offsets): init v39+ gate, MakeLibrary, open x2, reserved
  stubs, WBStart handler spawn + request/shutdown msgs.
  RUNTIME-IDENTICAL. Plane AMIGALIBS-319.
