# prometheus.library 2.5 — layout

## Hunks

| # | type | body | contents |
|---|------|------|----------|
| 0 | CODE | 0x998 B (0x266 L) | `moveq #-1,d0;rts` stub @0, RomTag @4, strings @0x20/0x34, helpers, rt_Init @0x4ce, all 18 vector bodies, `_settable` @0x826, `"Prometheus.card\0"` @0x8e6 |
| 1 | DATA | 0x4c B (0x13 L) | functab: 18 absolute longs `{0x5c6..0x96a}` + `ffffffff` |

RELOC32: h0 -> h0 {0x6,0xa,0x12,0x16,0x1a,0x4fc,0x516}
(RomTag self/name/id/init + the two `movel romtag.field.l` header copies),
h0 -> h1 {0x4dc} (init's `lea _functab`).

## Library base (84 B, built by exec MakeLibrary)

| off | field |
|-----|-------|
| 34  | SysBase |
| 38  | UtilityBase (utility.library v36) |
| 42  | Prometheus.card base — opened lazily by the DMA vectors |
| 46  | seglist |
| 50  | memory pool (CreatePool MEMF_CLEAR, puddle=thresh=752) |
| 54  | pb_BoardAddr (cd_BoardAddr of last scanned board) |
| 58  | pb_Cards MinList header (PCIBoard nodes) @ +58..+69 |
| 70  | pb_Requests List header (SpaceReq nodes) @ +70..+81 |

## PCIBoard node (~67 B, pooled)

| off | field |
|-----|-------|
| 0..7 | MinNode links in pb_Cards |
| 8    | pn_ConfigBase (cfg space base for this device = cfgbase + slot*0x2000 + func*256) |
| 12   | pn_TagList (vendor, device, class, revision, ...) |

## SpaceReq node (30 B, pooled; List in pb_Requests)

| off | field |
|-----|-------|
| 0..7 | ln_Succ/ln_Pred |
| 8    | ln_Type = 0xfe |
| 9    | ln_Pri = log2(size) (Enqueue order) |
| 14   | sr_Size |
| 18   | sr_Type (0=mem, 1=io) |
| 22   | sr_Tag -> tagitem receiving the assigned address |
| 26   | sr_CfgAddr -> the BAR longword to program |

## PCI config window

- cfg space base = `cd_BoardAddr + 0xf0000`; slot stride 0x2000,
  function stride 0x100.
- cfg+0 vendor/dev words, +4 command (set to 0x0700), +13 latency (0),
  +14 headertype (bit7 = multifunction), +0x10.. BARs, +0x30 ROM BAR.
- All config reads/writes are byte-swapped (little-endian PCI on a
  big-endian bus); index swizzle: long `off>>2`, word `off>>1 ^ 1`,
  byte `off ^ 3`.

## ConfigDev use

`cd_BoardAddr` @32 (read), `cd_BoardSize` @36 (read),
`cd_Flags` @14 (bit1 cleared after scan), `cd_Driver` @44 (set to pb).
