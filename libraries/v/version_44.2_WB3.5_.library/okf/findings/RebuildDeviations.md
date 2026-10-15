---
type: Finding
title: Rebuild deviations
description: Where the reconstructed binary differs from the shipped one.
---

# Rebuild deviations

`source/` builds a functionally equivalent but not byte-identical
binary (gcc -O2 -m68000 vs. the original compiler output):

- **Code size**: rebuilt code hunk is 0x12c bytes vs. 0x10c —
  gcc emits a6/a2 push-pop prologues around the exported functions
  and a `beq` with inverted branch polarity in LibClose.
- **Hidden probe**: byte-identical (hand-written `version_check.s`),
  including the in-.text obfuscated name and zero added relocs —
  LibInit takes its address via `lea sym(pc)` inline asm exactly
  like the original.
- **Stale d0 on LibClose early exit**: original branches to `rts`
  leaving d0 = caller garbage; reconstruction returns NULL.
- **RT_ENDSKIP**: original points at the second byte of the
  trailing pad word (odd address 0x10b); the reconstruction
  reproduces the same pad-byte placement, absolute value differs
  with code size.
- **Relocations**: identical count (7 RELOC32); positions 0x4c/0x54
  for the InitTable pointers match.

Vector order, RomTag fields, name/id strings, InitTable dataSize
(0x36), all base-field writes and all LVO semantics match.
