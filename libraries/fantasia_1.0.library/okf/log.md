---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2026-10-10

- Parsed hunk: single code hunk 0x290 bytes, 0x18 relocs (incl.
  absolute jmp targets in JoyButtons).
- RomTag AUTOINIT v1; EndSkip = InitTable (mid-module quirk).
- Functab absolute-long: Open/Close/Expunge/reserved/JoyDir/
  JoyButtons.
- LibInit stores sysbase@0x22, dos@0x26, seglist@0x2a; dead bne.
- LibClose tests flag via caller's a5 (bug, reproduced);
  Expunge uses stored SysBase, movem mismatch (d1 push/d2 pop).
- Decoded JOY1DAT quadrature → d3 (0-8) and CIAA/POTGOR → d2
  ({0,1,2,4}); ported to fantasia_hw.s verbatim.
- Reconstruction builds a valid HUNK library.

## 2026-10-15

- Rewrote as verbatim asm `source/fantasia_v.s` — byte-identical
  (md5 94eea1187a2d3fe15d2130c597f2897f).  gas canonicalizations
  had to be suppressed: `move.l #imm,dN` raw-emitted (vs moveq),
  `bne.l +4` raw-emitted, `jmp abs` raw-emitted as `4ef9`+`.long`
  (gas wanted PC-relative `4efa`), datatab terminator is `.long 0`.
- machine68k oracle RUNTIME-IDENTICAL: all 9 JOY1DAT decode cases
  (d3 0-8), all 5 CIAA/POTGOR combos (d2 {0,1,2,4}), deferred+real
  expunge, and the a5-flag Close defect verified (junk a5 -> flag
  not tested on lib).
