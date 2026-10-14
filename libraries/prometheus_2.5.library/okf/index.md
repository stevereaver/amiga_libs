# prometheus 2.5.library — OKF index

## Identity

| field    | value                                                              |
|----------|--------------------------------------------------------------------|
| libname  | `prometheus.library`                                               |
| version  | 2.5 — `"$VER: prometheus.library 2.5 (22.07.2003) (c) 2000-2003 by Matay."` |
| size     | 2728 bytes                                                         |
| format   | hunk: CODE(2456 B) + DATA(76 B: 18-long functab + ffffffff term)   |
| resident | COLDSTART (`rt_Flags = 0`), rt_Init -> h0+0x4ce (self-MakeLibrary) |
| purpose  | Driver library for the Matay "Prometheus" ZorroIII->PCI bridge: finds the Zorro board (manufacturer `0xad47`, product 1) via `expansion.library`, probes 4 slots x 1|8 functions of PCI config space at `cd_BoardAddr+0xf0000`, builds PCIBoard nodes with taglists + SpaceReq list, assigns BAR addresses, then serves config-space R/W (byte-swapped), tag attr get/set, interrupt add/remove, and DMA buffer calls forwarded to `Prometheus.card` v7. |

## Reconstruction

- **Approach**: pure 68k assembly, byte-identical target
  (vbcc/gcc-style compiled C: frame juggling, stack args, SysBase
  kept in lib+34, `moveal 4:w` unused — bases pulled from lib fields).
- **Source**: `source/prometheus.s` (all code + h1 functab),
  `source/Makefile`, `source/fixup.py` (reloc order).
- **Result**: `prometheus.library` byte-identical to the original.
- **Runtime**: `work/oracle.py` — fake exec (real MakeLibrary, MinList,
  pool ops), fake expansion/utility/Prometheus.card, fake ConfigDev
  with cfg space mapped into RAM; identical traces for init (full
  4-slot scan, BAR probing, WriteAddresses), Open/Close/Expunge,
  FindBoard, GetAttrs, cfg read/write (all three widths incl. the
  bfextu index swizzle), SetAttrs, int add/rem, DMA alloc/free,
  GetPhysicalAddress.

## Docs

- `functions/vectors.md` — all 18 vectors + internal scan engine.
- `structures/layout.md` — hunks, lib base, PCIBoard, SpaceReq, ConfigDev use.
- `findings/quirks.md` — quirks and inconsistencies.
- `log.md` — work log.
