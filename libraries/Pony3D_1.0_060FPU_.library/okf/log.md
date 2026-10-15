---
file: log
---
# Work log

- 2026-10-15: 060+FPU build — same 3-hunk skeleton as the 020 sibling but
  distinct codegen (hunk0 640B + hunk1 676B (060 scheduling) vs 424B 020, ~2000 byte diffs). hunk1 is a
  dense FP-instruction blob that desyncs objdump (f-line extension
  words) — emitted raw. fixup.py re-splits CODE into h0/h1 and splices
  the original REL32 tails (h0: 16->h0+4->h1+5->h2; h1: 2->h2).
  BYTE-IDENTICAL.
- machine68k oracle: init + 8 vectors + open/close-underflow/expunge.
  RUNTIME-IDENTICAL. Plane AMIGALIBS-289.
