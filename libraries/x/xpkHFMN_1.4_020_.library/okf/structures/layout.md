# xpkHFMN 1.4 — layouts

## Stream format
`u16 treeBytes` | serialized tree (preorder: '1' = internal child desc,
'0'+8 bits LSB-first = leaf) | `u16 inLen` | packed codes (MSB-first
per code).  Tree bytes counted in emitted longs; final partial long
padded by ADDX — X is always 1 on entry so the pad emits '1' then 0s.

## Pack workmem (alloc 0x1a0e = size long + 0x1a0a body, Sub[0]=body)

| off | content |
|-----|---------|
| +0x0002 | u16 freq[512] — [0..255] symbols, [0x100+n] internal nodes |
| +0x0402 | u16 heap[257] — 1-based min-heap of ids |
| +0x0606 | s16 parent[512] — sign = direction (+ = '1' side, - = '0') |
| +0x0a06 | u16 child[id][2] — +0 = '0'-side child, +2 = '1'-side |
| +0x120a | u32 code[256] — LSB-first leaf-up accumulation |
| +0x160a | u32 len[256] — only the low byte is used by the emitter |

## Unpack workmem (alloc 0x1004 = size long + 0x1000 body)

| off | content |
|-----|---------|
| +0x0000 | 4-byte trie nodes {u16 slot0='1' dir, u16 slot1='0' dir}; leaf content = 0xffffffSS (negative long = leaf mark) |
| +0x0800 | during build: long backptr per node (climb scratch); then 1024-word 10-bit fast table: positive = {10-len, sym} bytes, negative = nodeOffset-0x800 (resume walk) |

## Pack algorithm
histogram (u16) -> heap[1..n] = used syms descending -> heapify ->
n-1 merges (pop min, replace-with-last, sift; pop min2, insert
id=0x100+iter node: '+' parent on 2nd-pop, '-' on 1st; sift) ->
per-symbol parent walk collecting code bits LSB-first + filling child
records -> preorder tree emit -> data emit via BFINS-equivalent.
Single-symbol input gets a phantom sym-0 '0'-side sibling under root
0x101 so every leaf still gets a code.

## Descriptor (verified byte-exact)
name "Huffman", id 'HFMN', flags 9, chunk 0xfffe/0/0xfffe,
msgs Coding/Decoding/Coded/Decoded, DefMode=100.
Mode "dynamic": Upto=100, Flags=1, PackMem=0x1a0e, UnpackMem=0x1004,
PackSpeed=0x9d, UnpackSpeed=0x133, Ratio=0xf7, ChunkSize=0.
