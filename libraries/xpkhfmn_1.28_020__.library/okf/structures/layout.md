# xpkHFMN 1.28 — layouts

## Stream format (identical to HFMN 1.4)

`u16 treeBytes` | serialized tree (preorder: '1' = internal child,
'0'+8 bits LSB-first = leaf; root marker omitted — implicit) |
`u16 inLen` | packed codes (MSB-first per code, 020 BFINS order).

Tree bytes counted in emitted longs; final partial long padded via
ADDX — X=1 on pad entry so pad = '1' then 0s.

## Pack workmem (AllocMem 0x1a0a, MEMF_CLEAR — same layout as 1.4)

| off | content |
|-----|---------|
| +0x0002 | u16 freq[512] — [0..255] syms, [0x100+n] internal nodes |
| +0x0402 | u16 heap[257] — 1-based min-heap |
| +0x0606 | s16 parent[512] — sign = direction (+ = '1', - = '0') |
| +0x0a06 | u16 child[id][2] — +0 = '0' side, +2 = '1' side |
| +0x120a | u32 code[256] |
| +0x160a | u32 len[256] — low byte used |

The parent-table accesses are written as `lea wm+1540; op 2(a3,..)`
(i.e. base+2 offset in the EA) but land on the same +0x0606 array as 1.4.

## Unpack workmem (AllocMem 0x19fa, MEMF_CLEAR)

| off | content |
|-----|---------|
| +0x0000 | generated decoder code (template 28B + nodes 6B + leaves 12B) |
| +0x13fa | fixup stack {u32 node offset, u16 serial} 6B/entry |

## Descriptor (88 bytes at code+0x5e6)

`xi_XpkInfoVersion=1, xi_LibVersion=1, xi_MasterVersion=2,
xi_ModesVersion=0` (4 words), then:

- xi_Name → "HFMN"
- xi_LongName → "dyn. Huffman.020+ Version 1.28 " (trailing space)
- xi_Description → "fast dynamic Huffman compression/decompression."
- xi_ID = `'HFMN'`, xi_Flags = 9
- xi_MaxPkInChunk = 0xffff, xi_MinPkInChunk = 12, xi_DefPkInChunk = 0xffff
- msgs: "packing" / "unpacking" / "packed" / "unpacked"
- xi_DefMode = 0 (1.4 sibling uses 100)
- xi_ModeDesc → mode table; xi_Reserved = 6 zero longs

## Mode table (code+0x6b8)

{Next=0, Upto=100, Flags=0, PackMem=0x1a0a, UnpackMem=0x19fa,
 PackSpeed=0x103, UnpackSpeed=0xd1, Ratio=0xf7, ChunkSize=0x3f,
 name " normal " inline}

## Binary header quirks

- code+4: vestigial `.word 0x1a0a, 0x19fa` (the two alloc sizes as
  dead data right after the `moveq #-1; rts` entry stub)
- 20 dead bytes at 0x578: `nop + example node + example leaf +
  dbf + 0x47e5` — a generated-code sample, never referenced
- Datatab: byte@8=9, long@10=name, byte@14=6, word@20=1, word@22=28,
  long@24=idstr (`a008/800a/a00e/9014/9016/8018` opcodes)
