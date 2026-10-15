---
type: Structures
title: amigametaformat 6.0 layout
---

# Layout

- datasize 0x430 -> 34B node + 1044B private (3 lib bases,
  driver table, requester state).
- datatab@+0x2e: InitStruct byte commands (a0/90/80 opcodes)
  setting LN_TYPE=9, name/idstr/version fields.
- Driver-name string table @0xa8c..0xc20: 12 'AMF/amigametaformat-
  *.driver' paths (jmf, wmf, ai, dr2d, hpgl, ww, cgm, gem, eps,
  strip, file, strip, strip).
