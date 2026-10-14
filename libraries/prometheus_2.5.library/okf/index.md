# prometheus.library 2.5 — OKF index

`prometheus.library` 2.5 (22.07.2003) — Matay Prometheus PCI bridge (Zorro
III) driver library by Grzegorz Kraszewski. At boot it walks the
Prometheus PCI config space (4 slots x 1|8 functions at
`cd_BoardAddr+0xF0000`), probes every BAR with the `0xFFFFFFFF` write-back
trick, collects memory/IO space requests in a priority-sorted list
(`ln_Pri = log2(size)`) and assigns PCI addresses top-down from
`board+boardsize` (MEM window `board+1MB..board+boardsize`, IO window
`board+0x10000..board+0xF0000`). Found cards become `PCIBoard` nodes
(MinList at lib+58) whose inline taglist exposes Vendor/Device/Revision/
Class/SubClass/MemorySize0-4/MemoryAddr0-4/ROM/Owner/Slot/Function tags
(`0x6eda0000+`). Public API covers board enumeration
(FindBoardTagList), attribute get/set (only `PRM_BoardOwner` is settable),
PCI config-space read/write with byte-lane swizzling, interrupt server
add/remove, DMA buffer alloc/free (delegated to `Prometheus.card`, opened
lazily) and a virtual->physical window check.

- binary: `binary/prometheus_2.5.library` (2728 bytes, 2 hunks)
- source: `source/prometheus.s` — pure 68k asm (gas), single .text+.data
- build: `cd source && make` → byte-identical (md5
  `25a899335bb6689d619ebe1025edcd39`); `fixup.py` rewrites hunk0's
  RELOC32 into the original 2-group order
- oracle: `work/oracle.py` (machine68k, fake exec+utility+expansion+
  Prometheus.card + fake ConfigDev/PCI cfg space) — COLDSTART rt_Init
  with full board scan, all 18 vectors, deferred expunge; orig vs
  rebuild trace identical
- **requires 68020+**: uses `bfextu`, `extbl`, `tst.l an`, `moveq#n/notb`
  constant trick and scale-4 indexed addressing — `tst.l aN` is ILLEGAL
  on a plain 68000 (verified in the oracle: vectors into low memory)

## Layout

- hunk0 CODE, table 0x266 longs (2456B): DOS stub (`moveq #-1/d0; rts`),
  RomTag (COLDSTART, flags=0, ver 2, NT_LIBRARY, pri 0, EndSkip->0x1e,
  rt_Init->0x4ce), name + `$VER` strings, SizeToPri, AddRequest,
  QueryCard, WriteAddresses, ScanBoard, rt_Init, Open/Close/Expunge,
  reserved stub, FindBoardTagList, GetBoardAttrsTagList,
  Read/WriteConfig{Long,Word,Byte}, SetBoardAttrsTagList (+settable-tag
  array), AddIntServer, RemIntServer, "Prometheus.card" string,
  AllocDMABuffer, FreeDMABuffer, GetPhysicalAddress. Code body actually
  fills the whole table (0x998 bytes = 0x266*4) — no tail hunk quirk.
- hunk1 DATA, 0x13 longs (76B): MakeLibrary absolute function table —
  18 relocated vectors to hunk0 + `0xffffffff` terminator. Nothing else.

## Quirks (see findings/quirks.md for the full list)

- `tst.l aN`, `bfextu`, `extbl`, scale-2/4 indexed EA → library needs a
  68020+ despite being nominally a 68000-era Zorro card driver.
- `moveq #67,d0; notb d0` is the compiler's 2-byte-shorter way to load
  188 (`sizeof(PCIBoard)`).
- Board taglists are NOT `TAG_DONE`-terminated; they rely on the
  MEMF_CLEAR pool allocation zeroing the rest of the 188-byte node.
- `WriteConfig*` take (a0=board, d0=offset, d1=data) — the order the
  3.0 changelog describes as the "data/offset registers reversed" bug.
- `QueryCard` alloc-failure path writes the Owner/Slot/Function tags
  through a NULL node pointer (latent low-memory corruption).
- `GetPhysicalAddress` window is hardcoded `[board+0x100000,
  board+0x1FFFFFFF]` regardless of `cd_BoardSize`.
- hunk0 RELOC32 order is "7 offsets->h0 then 1 offset->h1" (not the
  linker's natural per-hunk grouping) — restored by `fixup.py`.

See `functions/vectors.md`, `structures/layout.md`, `findings/quirks.md`,
`log.md`.
