---
type: Log
title: Reconstruction log
---
# Log

- Single CODE hunk; entry stub returns -1 (V4.x returns 0).
- AUTOINIT word-offset functab, 10 vectors; dataSize 0x26.
  Null slots (-24/-42/-48/-60) share one moveq #0/rts at
  hunk+0x4a2 (word offset 0x023e).
- Descriptors are static: XpkInfo + a 4-entry LINKED
  XpkMode list (Autosizing -> LongByte -> WordByte ->
  ByteByte).  Order reversed vs V4.1's table.
- Mode dispatch is `cmpb` on the LOW BYTE of xsp_Mode:
  <=33 LongByte, <=67 WordByte, else ByteByte.  No
  AutoSize pass exists; mode 0 silently packs LongByte.
- Tags: encoder emits 33/67/100; decoder accepts 100/67/33.
  All self-consistent (V4.1 later regressed ByteByte to
  emitting mode-selector 90).
- LongByte = whole-input greedy scanner, 4-byte counts,
  run threshold 6 extras mid-stream (7 at tail).
- WordByte/ByteByte share a windowed scanner: window
  32767/127 positions, consumed-counter refills; run
  thresholds 4/3 extras mid-stream (+1 at tail).
- Decoder: `while src < inbuf+inlen-1`; tag dispatch,
  no output bound check, no xsp_OutLen write, -12 on
  unknown tag.
- Host test (native types fixed to 32-bit): 5676
  round-trips pass.  The only divergences from identity
  are shipped defects, all reproduced:
  * n=0 -> 1-byte output (unconditional seed read).
  * W/B tail: last byte dropped when it terminates a
    qualifying run (consumed-counter exits first).
  * W/B inputs < one window emit OOB memory as a run.
- LVO inventory: Remove(-252), FreeMem(-210) only.
- Inconsistencies filed in Plane.
