---
type: Structures
title: sz_aio_ahi 0.2 layout
---

# Layout

- datasize 0x430 -> 34B node + 1044B private (3 lib bases,
  driver table, requester state).
- datatab@+0x2e: InitStruct byte commands (a0/90/80 opcodes)
  setting LN_TYPE=9, name/idstr/version fields.
 Dependency strings inline: dos/intuition/graphics @0x1c0-0x1ef,
  ahi.device + gadtools.library @0xb1a-0xb43.
