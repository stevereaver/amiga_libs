---
file: defects
---
# Findings

- DREL16 tail: count/hunkno/offsets are 16-bit words; group terminated
  by a bare zero word. Loader-side word relocations (offsets
  0x6..0x68 patch resident + functab pointers).
- The single exported function (-30) performs a buffered RDB walk:
  AllocMem(644, MEMF_PUBLIC|CLEAR), AllocMem(4, ...), OpenLibrary
  expansion.library — matches observed trace.
- Close does not expunge-guard underflow beyond standard semantics;
  no defect observed in oracle runs.
- 68000 build; the `ptable_1.0(020)` sibling is a distinct compile
  (1146 byte diffs), reconstructed separately.
- This is the 68020 build: same vector layout as the 68000 sibling,
  different codegen (68020 addressing modes / muls.l). Functionally
  identical under the oracle.
