---
type: Log
title: Reconstruction log
---
# Log

- AUTOINIT word-offset functab, 10 vectors; dataSize 0x26.
- Decoded the mode dispatch (xsp_Mode vs 33/67/90) and the
  shared encoder core: tag byte + signed-count items,
  positive=run count+1, negative=literal 1-count.
- AutoSize: trials into the same buffer, argmin nonzero,
  re-run winner or keep ByteByte (ran last).
- Decoder: tag dispatch 100/67/33, no bound, no OutLen.
- FOUND the V4.1 tag defect: encoder emits 90 for
  ByteByte while the decoder expects 100. Cross-checked
  V3.1: emits and decodes 100. Reproduced faithfully —
  host test shows all tag-90 streams rejected (-12).
- Default mode is ByteByte (xi_DefMode 90) -> default
  output is undecodable; AutoSize breaks when ByteByte
  wins.
- Host test: 10002 round-trips pass (LongByte/WordByte/
  AutoSize non-ByteByte winners), 0 failures.
- LVO inventory: Remove(-252), FreeMem(-210) only.
- Inconsistencies filed in Plane (AMIGALIBS-40).
