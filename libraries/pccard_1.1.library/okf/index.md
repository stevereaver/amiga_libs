---
bundle: pccard_1.1.library
status: complete
updated: 2026-10-15
---
# pccard.library 1.1 (23.11.2002)

PCMCIA CIS tuple-parser library. Flat single CODE hunk
0x50d longs, AUTOINIT ver 1 (flags 0x80), RELOC32 tail
(49 slots, all -> h0). Opens utility.library v36 at init.
6 abs-long vectors: Open/Close/Expunge/reserved +
ParseTuple(-30) and FreeTuple(-36) taglist API.

- structures/layout.md, functions/vectors.md,
  findings/defects.md
