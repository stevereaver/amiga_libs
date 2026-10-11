# xpkSMPL 1.2 workmem

Workmem is allocated lazily on first pack/unpack with
`AllocMem(size, 0)` (UNCLEARED) and stored as
`xsp_Sub[0] = alloc + 4`; `*(ULONG*)alloc = size` for PackFree.
a5 == xsp_Sub[0] inside both routines.

## Pack workmem (0x3208 = 12808 bytes)

| Off | Size | Use |
|-----|------|-----|
| +0     | 4   | saved SP for the -17 bailout longjmp |
| +4     | 22  | sorted-list head node (link only, freq cleared) |
| +26    | var | 22-byte node arena: leaves then internals; after the
      |     | last leaf a 0xFF byte sentinel at next-slot sym |
| +11268 | 512 | freq[256] U16 histogram, reused as lentab |
| +11780 | 1024| codetab[256] U32 |

### 22-byte pnode (packed, unaligned longs on m68k)
| Off | Field |
|-----|-------|
| +0  | link (sorted-list next, 32-bit ptr) |
| +4  | freq U16 |
| +6  | sym S16 (leaf sym; <0 marks internal/sentinel) |
| +8  | parent ptr |
| +12 | left ptr |
| +16 | right ptr |
| +20 | mark U16: 0x4000 left-child, 0x8000 right-child, 0 root |

## Unpack workmem (0x1004 = 4100 bytes)

| Off | Size | Use |
|-----|------|-----|
| +0    | 2048 | binary trie: 4-byte nodes, U16 child offsets from a5
      |      | (+0 left, +2 right); leaf longs = `0xFFFFFF00+sym` |
| +2048 | 2048 | 1024-entry U16 fast table for 10-bit prefixes:
      |      | leaf -> `(unconsumed<<8)|sym` (positive),
      |      | deep  -> `nodeoff-0x800` (negative link) |

The 2048-byte trie region can hold at most ~511 interior nodes;
deep skewed trees overflow into the fast table (both live at the
same time) -- see findings.
