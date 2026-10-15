# workmem layout (0x3800 bytes, AllocVec, xsp_Sub[0])

| offset | size | use |
|--------|------|-----|
| 0x0000 | 0x10 | pack: xsp/src/inlen slots; unpack: binary trie root |
| 0x0000 | 2048 | unpack decode trie: 4-byte nodes {U16 link0, U16 link1}, leaf = 0xffffff00\|sym |
| 0x0010 | 24 | pack sorted-list head node |
| 0x0028 | ~510*24 | pack node arena: leaves then internals; slot after last leaf keeps sym=0xffff sentinel |
| 0x0800 | 2048 | unpack 1024-entry U16 fast table, indexed by next 10 bits |
| 0x3010 | 256 | UBYTE code lengths per symbol |
| 0x3110 | 1024 | ULONG code values per symbol (right-justified) |
| 0x3510 | 512 | UWORD delta histogram |
| 0x3710 | 240 | slack |

## pack node record (24 bytes)

| off | field |
|-----|-------|
| +0  | next (sorted linked list) |
| +4  | UWORD freq |
| +6  | UWORD sym (0xffXX on the sentinel/internals => stops the codegen scan) |
| +8  | parent |
| +12 | child0 (edge 0x4000) |
| +16 | child1 (edge 0x8000) |
| +20 | UWORD edge marker |
| +22 | pad |

## fast table entries

- positive: `steps<<8 | sym` -- leaf found after consuming
  10-steps of the 10 fetched bits; the decoder adds `steps` back to
  the bit index and `sym` to the delta accumulator
- negative: `link - 0x800` -- the 10-bit prefix is interior; the
  decoder reads the LONG trie node at wk+0x800+(link-0x800)=wk+link
  and continues the bit-by-bit walk
