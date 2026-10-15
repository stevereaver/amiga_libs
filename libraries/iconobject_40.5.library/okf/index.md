# iconobject.library 40.5

- **Identity**: `iconobject.library`, version 40.5, built 13 Sep 2005
  20:01:11 with SAS/C 6.58. Copyright 1999-2006 The Scalos Team.
  A Scalos component: loads "icon" datatypes objects (via
  `datatypes/<name>.datatype` sub-class libraries) found by scanning
  `DEVS:Datatypes/` for `#?.info` files parsed with iffparse.
- **File**: `binary/iconobject_40.5.library`, 3080 bytes,
  md5 `ee8b8bffa7aa63500a4b3f51f527457c`
- **Rebuild**: `source/iconobject.library` — BYTE-IDENTICAL (same md5).
- **Oracle**: `work/oracle.py` — RUNTIME-IDENTICAL (init, open scan
  incl. iffparse/dos/datatype stubs, all 11 vectors, deferred expunge).

## Hunk map

| hunk | type | file off | size | relocs |
|------|------|----------|------|--------|
| 0 | CODE (0x3e9) | 0x24 | 0x23f LW = 2300 B | RELOC32: ->h0 {0x862}, ->h1 {59 offs, hash order} |
| 1 | DATA (0x3ea) | 0xa34 | 0x5c LW = 368 B | RELOC32: ->h0 {12 offs desc}, ->h1 {6 offs desc} |

Header `0x3f3`, tablesize 2, hunk sizes [0x23f, 0x5c], no mem flags.

Quirk: the reloc records are NOT sorted — hunk1's groups run descending
(0x128..0x110, then 0x13c, then 0x10c..0x100), and hunk0's ->h1 group is
in SAS/C linker hash order. fixup.py rewrites them verbatim.

## RomTag / InitTable (in DATA hunk, +0x140 / +0x130)

- rt: RTC_MATCHTAG 4afc, EndSkip +0x15a, RTF_AUTOINIT, ver 40,
  NT_LIBRARY, pri 0, name +0x0, idstr +0x14, init +0x130.
- InitTable: dataSize 0x68, functab +0x100, **no InitStruct data
  table**, initFn = code+0x6de.
- initFn: lib+0x16 <- rev 5, lib+0x22 <- seglist, gd+0x15c <- SysBase,
  then _openlibs(lib): InitSemaphore(lib+0x2a), NewList(lib+0x58),
  OpenLibrary x4 v39 (iffparse->gd+0x16c, dos->+0x168,
  intuition->+0x160, utility->+0x164). On dep failure -> _closelibs
  -> init returns 0 -> caller expunges (initfn calls _expunge itself
  on _openlibs failure and returns 0).
