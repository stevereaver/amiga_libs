---
type: Finding
title: Rebuild deviations
description: Where the reconstructed binary differs from the shipped one.
---

# Rebuild deviations

`source/` builds a functionally equivalent but not byte-identical
binary (gcc -O2 -m68000 vs. the original compiler output):

- **Code size**: rebuilt code hunk is 0xdc bytes vs. 0xc0 —
  gcc emits a6/a2 push-pop prologues around the exported functions
  (the original uses `exg d0,a5` and bare a6 access) and a `beq`
  with inverted branch polarity in LibClose.
- **Stale d0 on LibClose early exit**: original branches to `rts`
  leaving d0 = caller garbage; reconstruction returns NULL.
- **RT_ENDSKIP**: both point at the trailing pad word region;
  absolute value differs with code size.
- **Relocations**: identical count and positions (7 RELOC32:
  RomTag at 0x06/0x0a/0x12/0x16/0x1a, InitTable at 0x4c/0x54).

Vector order, RomTag fields, name/id strings, InitTable dataSize
(0x2a), revision stamp (29) and all LVO semantics match.
