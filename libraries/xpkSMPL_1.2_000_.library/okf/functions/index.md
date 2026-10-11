# xpkSMPL 1.2 functions

All offsets are hunk-relative in the shipped binary.

## Lifecycle
| Vector | Hunk | Notes |
|--------|------|-------|
| LibOpen  (-6)  | 0x0b2 | standard opencnt++ |
| LibClose (-12) | 0x0c0 | opencnt--, expunge when DELEXP |
| LibExpunge(-18)| 0x0d2 | Remove + FreeMem |
| null (-24,-48) | 0x000 | `moveq #0,d0 / rts` at hunk start |

## -30 XpksPackerInfo (0x128)
`movea.l #xpkinfo(pc),a0; rts` -- returns the static XpkInfo
descriptor block.

## -36 XpksPackChunk (0x130)
Args come through the saved-d7 arg block convention (the XPK
master passes the same XpkSubParams pointer in both regs).

1. lazily AllocMem 0x3208 (flags 0, uncleared) -> xsp_Sub[0]=alloc+4;
   a5 = Sub[0]; `a5@` saves SP for the -17 longjmp bailout
2. delta histogram into 256 U16 at a5+11268 (`SUBQ.L/DBF` count)
3. sorted leaf list at a5+4 head, 22-byte nodes at a5+26,
   inserted BEFORE first node with freq >= new (bhi scan)
4. merge two smallest until one remains; merge-node reinsert
   splices the rest-list (insert before first freq >= merge)
5. code collect: walk leaf->root via parent; each marker's bit15
   (0x4000 left=0, 0x8000 right=1) is roxr'd into bit31 of the
   code accumulator, then `lsrl` right-justifies -- emitted
   MSB-first = root-down order
6. emit: `wr16` sig 1, 256-entry nibble table (0 nibble absent,
   15+nibble for len 15..30, code bits follow each present len),
   then one code per delta; final `wr32` pad

## -54 XpksUnpackChunk (0x390)
1. checks sig word == 1, else -26
2. lazily AllocMem 0x1004 -> xsp_Sub[0]=alloc+4 (a5)
3. window reader: `win` holds pending bits in low `bits` slots,
   `swap; move.w (a6)+; +16` refill; returns `win>>bits`
   (UNMASKED -- callers mask)
4. reads 256 (len,code) pairs, inserts into 4-byte-node trie at
   a5+0 (word child offsets, arenapos from 4); single-branch root
   fixup mirrors left into right
5. builds 1024-entry fast table at a5+2048: per 10-bit prefix,
   trie-walk up to 10 steps; leaf -> `(unconsumed<<8)|sym` byte
   pair, deep node -> `nodeoff-0x800` link (negative)
6. decode: 10-bit table probe; positive entry emits sym & gives
   back unused bits; negative walks the trie with `btst d6,d7`
   single-bit steps (bit=1 -> right, else swap->left); delta
   accumulator `acc += sym` writes output

## -42/-60 XpksPackFree (0x110)
`Sub[0]-4 -> FreeMem(size long)`; leaves xsp_Sub[0] stale.
