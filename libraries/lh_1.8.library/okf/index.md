# lh.library 1.8 -- OKF index

`lh.library 1.8 (16 Dec 1990) (c) Copyright 1990 by Holger P. Krekel &
Olaf Barthel, all rights reserved.` -- runtime library implementing the
LHa/LZH adaptive-Huffman codec (the same engine used inside `LhA`).
Written in hand-optimised 68000 assembly; single CODE hunk, AUTOINIT.

## Identity

- Name: `lh.library`, version 1, revision 8
- RomTag: AUTOINIT, NT_LIBRARY, pri 0, InitTable @0x94
- InitTable: dsize 0x22 (plain `struct Library`), absolute functab
  @0xa4, InitStruct datatab @0xc8, initfn @0xec
- 8 vectors (48-byte negative region)

## Hunk layout

- One CODE hunk, 0x2aa longs / 2728 bytes.
- RELOC32: single group, target hunk 0, 21 entries -- order is NOT
  ascending: the two code relocs 0x206/0x1ee (jmp abs.l operands in the
  validate vectors) come first, then header/table relocs 0x6..0xee.
  `fixup.py` rewrites the group after linking.
- Data embedded in code: packed symbol tables at 0x428..0x627
  (256 words) and 0x9b2..0xa31 (64 words); seglist cell at 0xe8.

## Vector map

| LVO | Offset | Name | Summary |
|-----|--------|------|---------|
| -6  | 0xf4   | Open       | opencnt++, clears deferred-expunge |
| -12 | 0x102  | Close      | opencnt--, deferred expunge |
| -18 | 0x116  | Expunge    | inlined Remove + FreeMem, returns seglist |
| -24 | 0x14e  | stub       | returns 0 |
| -30 | 0x152  | AllocHandle| d0!=0 -> 4500B model else 40000B, +28B handle |
| -36 | 0x1aa  | FreeHandle | frees model + handle |
| -42 | 0x1ce  | Encode     | validate (size>=40000, src/len/dst != 0) -> engine 0x628 |
| -48 | 0x1f6  | Decode     | validate (src/dst != 0) -> engine 0x210 |

See [functions/vectors.md](functions/vectors.md),
[structures/layout.md](structures/layout.md),
[findings/quirks.md](findings/quirks.md).

## Verification

- `source/lh.s` + `source/Makefile` + `source/fixup.py` produce a
  byte-identical binary (MD5 7ce6d7579d6be725127c678abe46c4fa).
- `work/oracle.py` (machine68k): init via InitTable+InitStruct,
  lifecycle incl. deferred expunge returning the seglist, handle
  alloc/free for both model sizes, all validation-failure paths, and a
  full encode->decode round-trip (200 incompressible bytes -> 218
  encoded -> 200 decoded, bit-exact). Original and rebuilt produce
  identical traces.
