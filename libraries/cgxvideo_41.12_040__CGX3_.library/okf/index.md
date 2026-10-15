---
bundle: cgxvideo_41.12_040__CGX3_.library
status: complete
updated: 2026-10-15
---
# cgxvideo.library 41.12 (4.8.99) "68040 Version" (CGX3)

phase5 digital products CyberGraphX V3 video/overlay driver
library (written by F.Mariak, (c) 1996-1999). 4 hunks:
CODE h0 0x21c + DATA h1 0x24 + CODE h2 0x1278 + CODE h3
0x80 (+HUNK_SYMBOL debug tail). AUTOINIT v41 rev12,
abs-long functab (15 vectors). 6268 B,
sha256 731781d5e2425e1091b8b66a3497c43e4ef648264c0bdb01a10db6e8bd7c91d4,
md5 30dae56703803fa91478624113eda731.

Sibling of the 020 build: binaries differ in exactly ONE
byte (file offset 0xa9 — '2' vs '4' in the idstring
"68040 Version"). Same code, same relocs, same symbols.

- structures/layout.md, functions/vectors.md,
  findings/defects.md, log.md
