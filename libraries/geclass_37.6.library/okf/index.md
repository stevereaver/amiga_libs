---
type: Index
title: geclass_37.6.library — OKF index
---

# geclass_37.6.library — OKF index

- Binary: `binary/geclass_37.6.library` (2,964 bytes / 0xb94;
  md5 `bfecf92799ad9ca83f6a1907af676830`)
- Identity: `$VER`-style id string `GEClass 37.6 (16 Dec 1994)\r\n`;
  resident name `geclass.library`, version 37, revision 6,
  `rt_Type = NT_LIBRARY`, `rt_Flags = RTF_AUTOINIT`, pri 0.
- Kind: BOOPSI/Intuition helper library.  LibInit `MakeClass()`es a
  private subclass of `frameiclass` (classID 0, dispatcher hook entry
  at code+0x6ac) stored as the library's "GetFileImageClass", then
  opens `iff.library` and grabs its -30 vector result as the
  `textfieldgclass` class.  Two exported vectors (-30/-36) wrap
  `NewObjectA`/`DisposeObject` and remap the private class names
  `getfileiclass` / `textfieldgclass` onto those class pointers.
- Hunks: h0 `HUNK_CODE` 0x2bb longs (0xaec bytes); h1 `HUNK_BSS`
  0x30 longs (0xc0 bytes, all private state, reached by absolute
  `lea _bss:l` sites relocated against hunk1).  See
  `structures/layout.md` for the full map and the exact RELOC32
  group order (the h0->h0 group is stored in nonstandard descending
  order and reproduced verbatim by `source/fixup.py`).
- Vectors: six, absolute-pointer functab at code+0xba terminated by
  -1: Open(-6) 0x198, Close(-12) 0x1a8, Expunge(-18) 0x1bc,
  Null(-24) 0x204, MakeNewObject(-30) 0x738, DisposeObject(-36)
  0x744.  Details in `functions/vectors.md`.
- CPU: nominally 68000 target (no AttnFlags gate in LibInit) but the
  code uses `rtd` (68010+) and one `trapf` (68020+); see
  `findings/quirks.md`.
- Reconstruction: `source/geclass_h0.s` (all of h0 — RomTag,
  InitTable, datatab, functab, code, strings, dispatch table,
  border coordinate table), `source/geclass_h1.s` (BSS),
  `source/Makefile` + generated `hunks.x` linker script,
  `source/fixup.py` (restores original hunk tags / RELOC32 order).
  `make` produces `source/geclass.library`, md5-identical to the
  original (first build matched).
- Oracle: `work/oracle.py` (machine68k, CPUType.M68020) — loads both
  hunks, applies relocations, stubs exec/intuition/graphics/utility/
  iff vectors, performs InitTable AUTOINIT by hand, then exercises
  every vector, the private-class dispatcher (OM_NEW tag defaults,
  IM_DRAW pen/PolyDraw paths, default supermethod), object
  creation/name mapping, DisposeObject passthrough, open/close,
  busy and deferred expunge, plus two init-failure paths
  (utility.library missing -> longjmp cleanup; iff.library missing
  -> soft fail).  Logs from the original and the rebuild are
  byte-for-byte identical (85 lines, `work/orig.log` vs
  `work/new.log`).

## Layout of this bundle

- `structures/layout.md` — RomTag/InitTable/datatab/functab offsets,
  BSS map, dispatcher jump table, string table
- `functions/vectors.md` — vector map + per-LVO behaviour, dispatcher
  methods, internal helpers
- `findings/quirks.md` — noncanonical encodings, compiler artifacts,
  CPU-level oddities, behavioural quirks
- `log.md` — chronological work log
