---
file: log
---
# Work log

- 2026-10-15: xpkSHR3 3.0 (020) — flat single-hunk XPK
  sublib. Raw .byte transcription of h0 + fixup restoring
  the 2B overrun + RELOC32 tail; BYTE-IDENTICAL.
- Oracle: full SHR3 pack/unpack harness — real 16B packed
  stream, round-trip via both decoder flavours, mode-table
  walk, header reject, deferred expunge; RUNTIME-IDENTICAL
  (invalids: 0). Plane AMIGALIBS-333.
