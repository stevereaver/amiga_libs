---
file: log
---
# Work log

- 2026-10-15: multifunction 38.1 — single-hunk AUTOINIT,
  resident+InitTable+code+data all in h0, RELOC32 53->h0.
  Raw .byte x1 + tail splice fixup; BYTE-IDENTICAL (5432B).
  Oracle traces all 31 vecs + open/close/expunge under exec +
  commodities/intuition/graphics/dos/misc.resource/timer stubs;
  RUNTIME-IDENTICAL (39,799,144 deterministic invalids — v-42
  smashes the lib's own jump table, so late close/expunge run
  wild through unmapped space until the insn budget expires).
  Plane AMIGALIBS.
