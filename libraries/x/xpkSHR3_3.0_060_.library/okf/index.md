---
bundle: xpkSHR3_3.0_060_.library
status: complete
updated: 2026-10-15
---
# xpkSHR3.library 3.0 (060) (1 Oct 2013, Matthias Meixner)

XPK 'SHR3' (Shrink v3) slow compressor — 060 build, sibling of the
020 build. Single CODE hunk; packed AUTOINIT resident; in-hunk
InitTable@+0x64 with a word-offset functab; 10 vectors. Shrunk-
length-less stream variant of SHRI: 1-byte flag header, unpacked
length taken from xsp+0x10, inlined 64:16 range-coder division.
The 060 build differs from the 020 sibling only in codegen: all six
64-bit `mulu.l` ops (060-unimplemented/trapping) are inlined as
two-`mulu.w` expansions, the decoder moved +0x10, the data tail
+0x2e, and the long name reads 'Shrink 020-060 V3.0'.

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks + full 020-build diff
