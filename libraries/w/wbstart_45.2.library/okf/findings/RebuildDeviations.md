---
type: Finding
title: RebuildDeviations
description: Where the reconstruction differs from the shipped binary.
timestamp: 2026-10-15T03:51:25Z
---

# Rebuild deviations

**None — byte-identical** (`source/wbstart_h0.s` + `fixup.py`,
md5 `45964497863bb8fbb534faed27da44fa`).

Unlike the 45.1 original (HUNK_DREL32 word records), this build
ships plain **HUNK_RELOC32** tails on both hunks — but the CODE
hunk's first group lists its two offsets non-sorted
(`{1dc, 1cc}`, i.e. the `strncat` call site before `strncpy`),
and GNU ld emits them ascending.  `fixup.py` splices the
original's RELOC32 sections over the linker's after asserting
the (hunk, offset-set) groups agree.

The two absolute `jsr` calls into the dead/called string
routines (code+0x1cc, +0x1dc) had to be emitted as raw
`0x4eb9` + `.long sym`: gas relaxes a defined `.text` symbol to
`jsr pc@(disp)`, which would both shrink the hunk by 4 bytes
and lose the hunk0 self-relocations the original carries.

The retained C model (`make cmodel`) still shows the old
deviations: code hunk differs entirely (GCC codegen vs the
compiled-SAS/C original), while its `.data` hunk was already
byte-layout identical.  All API/tag names in the reconstruction
are reconstructed; the binary exports none.
