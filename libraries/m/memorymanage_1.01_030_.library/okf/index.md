# memorymanage.library 1.01 — OKF index

Binary: `binary/memorymanage_1.01(030).library` (1624 bytes, single CODE hunk)
ID string: `memorymanage 1.01 (c) 2000`
CPU: **68030 required** — every public API runs PMMU instructions that do
not exist on 68000/010/020 and whose register formats differ on
68040/060 (which use different CRP/TC encodings).

## What it is

A 68030 PMMU page-management library. It builds a three-level
Amiga-style page table (root → level B → level C) and provides
enable/disable of translation, incremental mapping, MMU context
save/load, and virtual→physical translation via `ptestr`.

## Vectors (11 + -1L terminator, LONG absolute functab)

| LVO | Target | Function |
|----:|--------|----------|
| -6  | lib.s | LibOpen — opencnt++, clears flag3, returns base |
| -12 | lib.s | LibClose — opencnt--, tail-branches to expunge on flag3 |
| -18 | lib.s | LibExpunge — unlink + FreeMem of base |
| -24 | lib.s | reserved — return 0 |
| -30 | mm_enable — save PMMU state, alloc+init root table, load ctx |
| -36 | mm_disable — restore saved descriptors / reload saved ctx, free tables |
| -42 | mm_map (a0=virt, a1=phys, d1=flags) — build B/C levels for one page |
| -48 | mm_mapid (a0=virt) — wrapper: mm_map(va, va, 0) identity map |
| -54 | mm_saveregs (a0=24-byte buf) — PMOVE CRP/SRP/TC into buf |
| -60 | mm_loadregs (a0=24-byte buf) — PMOVE buf into CRP/SRP/TC, PFLUSHA |
| -66 | mm_vatophys (a0=virt) — PTESTR level-7 read, returns phys page |

All PMMU routines run via Exec `Supervisor()` (a5 = routine).

## Library base layout (datasize 0x4f)

| off | field |
|----:|-------|
| 0x22 | seglist |
| 0x26 | rootinfo (aligned root node ptr) |
| 0x2a | freelist (node pool head) |
| 0x2e | saved[24] — prior CRP/SRP/TC image |
| 0x4c | usecount |
| 0x4e | foreign flag (nonzero = PMMU was already active) |

## Files

- `source/memorymanage_lib.s` — RomTag, strings, InitTable, functab,
  lifecycle, PMMU supervisor bodies + static ctx blocks, `mm_map`,
  `mm_mapid`
- `source/memorymanage.c` — lifecycle C functions, enable/disable,
  ctx save/load wrappers, vatophys
- `okf/algorithms/pagetables.md` — 3-level table construction
- `okf/functions/vectors.md` — per-vector detail
- `okf/structures/layout.md` — base/node/descriptor layouts
- `okf/findings/defects.md` — shipped defects/quirks
