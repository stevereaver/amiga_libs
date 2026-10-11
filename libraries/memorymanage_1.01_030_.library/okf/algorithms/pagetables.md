# memorymanage.library — page table construction

## Hierarchy

68030 three-level tree, all descriptor entries 4 bytes, DT field in
descriptor byte 3 bit 1 (type-1 table / page descriptors).

| Level | Entries | Span/entry | Index bits (from VA) | Alloc size |
|-------|--------:|-----------:|----------------------|-----------:|
| Root  |     128 |     32 MB  | VA[31:25]            |     0x220  |
| B     |     128 |    256 KB  | VA[24:18]            |     0x220  |
| C     |      64 |      4 KB  | VA[17:12]            |     0x120  |

Alloc size = table bytes (512 / 256) + 16-byte align slack + 16-byte
node record appended at the end of the block.

## Node record (appended after each table)

`{ next, block, descaddr, olddesc }` — freelist linkage, the raw
AllocMem pointer for FreeVec, the address of the parent descriptor
that pointed to this table, and that descriptor's previous value so
`mm_disable` can restore the parent tree.

## mm_map flow (a0=virt, a1=phys, d1=flags)

1. `virt &= ~0xfff`, `phys &= ~0xfff`.
2. `d1` carries flags: low bits select which of root/B/C index
   computations apply (bit-tests decide whether B and C levels are
   built). With d1=0 (`mm_mapid`), all levels are built.
3. Root index `d1 = rol.w #9,va >> 2 & 0x1fc` (top 7 bits). If the root
   entry's DT bit (`btst #1,(a2,d1.w*4+3)`) is clear, a level-B table
   is AllocMem'd, filled with 128 entries `i*256KB+1`, node-linked,
   and the root descriptor is pointed at it.
4. Same pattern at level B using VA[24:18] → level C table, 64 entries
   `i*4KB+1`.
5. Level C entry `VA[17:12]` gets the physical page (with flag bits
   from d1 OR'd into the descriptor low bits).

## Fill loops

Each new table is pre-populated with incrementing type-1 descriptors
(`base+i*span+1`) — an identity template the caller can override.
GCC's codegen uses a `dbf`+wrap tail rather than the original's
accumulate-until-wrap `bne`; both run exactly N iterations.

## Supervisor bodies

- `_mm_sup_load`: `pmove a0@,crp; pmove a0@(8),srp; pmove a0@(16),tc;
  pflusha; rte` — encodings verified byte-exact vs original.
- `_mm_sup_save`: reverse direction, no pflush.
- `_mm_sup_ptest`: `ptestr #1,a0@,7,a1; rte` — `f010 9f31 4e73`.
- `_mm_ctx_enable` / `_mm_ctx_disable`: static 24/28-byte blocks of
  pmove operands + `pflusha; rte`; `mm_enable` patches root-pointer
  bytes 4..7/12..15 of the enable block at runtime.
