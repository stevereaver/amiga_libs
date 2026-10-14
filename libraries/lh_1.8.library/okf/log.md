# lh.library 1.8 -- work log

- Parsed hunk: single CODE hunk, 0x2aa longs (2728B); RELOC32 one group
  of 21 entries targeting hunk 0 (order: 0x206,0x1ee then 0x6..0xee).
- RomTag @4 AUTOINIT v1.8 NT_LIBRARY; InitTable @0x94 dsize 0x22;
  functab 8 absolute vectors; InitStruct datatab fills type/name/flags/
  ver/rev/idstr.
- Identified as lh.library (Krekel & Barthel LHa codec runtime):
  -30/-36 handle alloc/free, -42 encode engine @0x628, -48 decode
  engine @0x210. Adaptive Huffman + binary search tree match finder,
  max match 60, end marker symbol 316.
- Transcribed all 2728 bytes verbatim to source/lh.s (incl. both packed
  word tables emitted as .short, 60x unrolled copy loop, mid-loop jmp
  dispatch preserved as raw 4efb 707e encoding).
- Build: m68k-amigaos-gcc -m68000, nostdlib link, fixup.py restores
  original RELOC32 order. Result byte-identical to original
  (MD5 7ce6d7579d6be725127c678abe46c4fa).
- machine68k oracle: AUTOINIT init incl. InitStruct, lifecycle with
  deferred expunge returning seglist, both model sizes, every
  validation-failure branch, encode->decode round-trip (200B random
  data -> 218B -> 200B identical). Original vs rebuilt traces identical
  (RUNTIME-IDENTICAL), incl. shared invalid-read pattern after library
  teardown.
