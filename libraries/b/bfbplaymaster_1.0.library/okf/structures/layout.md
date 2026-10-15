---
type: Structures
title: bfbplaymaster 1.0 layout
---

# Layout

- datasize 0xb2 -> 34B node + 144B private.
- datatab@+0x4d4 (InitStruct).
- Inline data: 13 'replayers/bfbplay*.library' paths @0x5e-0x1e3,
  dep names (dos.library, audio.device) @0x1e4, 16 error strings
  @0x201-0x46e, module-magic descriptor table inside code
  @0xb50-0xcd0.
