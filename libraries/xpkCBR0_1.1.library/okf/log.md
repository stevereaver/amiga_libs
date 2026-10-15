---
type: Log
title: Reconstruction log
---

# Log — xpkCBR0_1.1.library

- Scanned: 948-byte CODE hunk; XPK sublibrary family
  (entry returns -1, word-offset functab, AUTOINIT).
- Phase 1: mapped hunk layout — descriptors are
  runtime-initialised (dataSize 0xaa), all 10 functab
  word offsets resolved.
- Phase 2: decoded both codecs — CBR0 is the simplest
  byte-RLE (literal h+1 / repeat 257-h).  Simulated the
  exact encoder control flow incl. the counter-underflow
  exit to verify run-segment headers (0x81 = 128-byte
  run) — round-trips consistent for all run lengths.
- Phase 3: C reconstruction on the FRLE template
  (two-pass genfunctab for the word-offset table);
  LibInit writes every descriptor field like the
  original — compiled code verified field-for-field.
  Host round-trip test: 20k random chunks, 0 failures,
  45 inputs correctly rejected by the -17 expansion
  guard (matches shipped semantics).
- Phase 4: this OKF bundle; OOB-read defect noted in
  findings (same class as the xpkFRLE encoder defect).

- 2026-10-15: byte-verbatim asm reconstruction
  (`source/xpkCBR0_h0.s`) + descending-RELOC32 fixup.py;
  `cmp` identical.  machine68k oracle identical across
  every vector incl. codec edge cases, the +256 output
  slack, the run-loop past-end read, and the real
  deferred-expunge path.
