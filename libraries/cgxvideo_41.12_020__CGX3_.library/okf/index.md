---
bundle: cgxvideo_41.12_020__CGX3_.library
status: complete
updated: 2026-10-15
---
# cgxvideo.library 41.12 (4.8.99) "68020 Version" (CGX3)

phase5 digital products CyberGraphX V3 video/overlay driver
library (written by F.Mariak, (c) 1996-1999). 4 hunks:
CODE h0 0x21c + DATA h1 0x24 + CODE h2 0x1278 + CODE h3
0x80 (+HUNK_SYMBOL debug tail). AUTOINIT v41 rev12,
abs-long functab (15 vectors). 6268 B,
sha256 0b359e17c99765ebbcc773375c5d48365baee09e17a09117c5709bc5129e49a7,
md5 d241854485ba9987729dabb3b0de82a8.

Sibling of the 040 build: binaries differ in exactly ONE
byte (file offset 0xa9 — '2' vs '4' in the idstring
"68020 Version"). Same code, same relocs, same symbols.

- structures/layout.md, functions/vectors.md,
  findings/defects.md, log.md
