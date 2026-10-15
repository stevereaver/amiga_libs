---
file: log
---
# Work log

- 2026-10-15: Parsed hunk layout (1 CODE hunk, DREL16 tail). Emitted
  verbatim transcription (raw head through functab, mnemonic code).
  fixup.py splices the DREL16 group. BYTE-IDENTICAL.
- machine68k oracle: init, all 5 LVOs incl. the -30 RDB scan entry
  (AllocMem x2 + OpenLibrary expansion.library path traced).
  RUNTIME-IDENTICAL. Plane AMIGALIBS-280.
- 2026-10-15: 68020 sibling build — same InitTable/functab layout as
  the 68000 build but distinct codegen (1146 byte diffs). Same
  verbatim pipeline. BYTE-IDENTICAL + RUNTIME-IDENTICAL.
  Plane AMIGALIBS-281.
