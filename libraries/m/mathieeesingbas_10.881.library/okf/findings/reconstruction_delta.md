---
type: Finding
title: Byte-identical reconstruction
description: The rebuilt library is byte-identical to the shipped binary (verbatim asm + tail fixup).
---

# Byte-identical reconstruction

`source/mathieeesingbas.s` is a verbatim transcription of the 0x1c8-byte
CODE hunk (RomTag, InitTable, seglist cell, word-offset functab,
InitStruct stream, all 16 vector bodies, strings, pad words).
`make` assembles it with `-m68000 -Wa,-m68881` and links with
`-nostdlib -nostartfiles -Wl,-s`.

All 68881 F-line words assemble byte-identically through GNU as
(`fmoves`, `fmovel`, `fadds`, `fsubs`, `fmuls`, `fdivs`, `fintrzs`,
`fcmps`, `fbule`, `fbuge`, `fmovel #imm,fpcr`).

## Tail fixup

GNU ld emits a long-format `HUNK_RELOC32` (0x3ec) chunk for the eight
absolute longs in the RomTag/InitTable.  The shipped binary carries the
compact 16-bit form (chunk id **0x3f7** = RELOC32SHORT / DREL16):

```
0000 03f7                    ; hunk id
0008 0000                    ; [count:word=8][hunk:word=0]
0028 0024 0020 0018          ; 8 descending word offsets
0014 0010 0008 0004
0000 0000                    ; count-0 terminator (+ pad to 4)
0000 03f2                    ; HUNK_END
```

`source/fixup.py` verifies the ld-emitted reloc set equals
{0x04,0x08,0x10,0x14,0x18,0x20,0x24,0x28} and rewrites the file into the
0x3f7 form, then asserts byte-identity against `binary/`.

Result: `md5 = 3e7f4b125c23ac45849af05ebcd587ce` — identical for
`binary/mathieeesingbas_10.881.library` and the rebuild.

## Earlier C model

The previous session's multi-file C+asm build (valid, semantically
equivalent, larger) is kept for documentation under `make cmodel`
(`mathieeesingbas-c.library`).  It is superseded by the verbatim build.

## Oracle

`work/oracle.py` (machine68k) loads either binary, replicates the
AUTOINIT build, and emulates the small 68881 subset through the line-F
exception vector.  `orig.log` and `rebuild.log` are identical.
