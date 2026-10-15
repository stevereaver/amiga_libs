---
file: layout
---
# MCPSupport2 6.1s layout

File 3844B. Single hunk: CODE 0x380 longs = 3584B @file+0x20.
Tail: RELOC32, 52 slots ->h0, HUNK_END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #0,d0 / rts` stub |
| 0x04 | Resident AUTOINIT v6 rev6, pri 0; name->0x1e id->0x32 init->0x78 |
| 0x1d | name `mcpsupport2.library` (stray 'x' byte @0x1d) |
| 0x32 | idstr `$VER: MCPSupport2.library 6.1s (15.12.06)` + `(c)2002-2006 by D.Gropp` |
| 0x78 | InitTable: dsz=0x22, functab->0x88, datatab->0xc0, initfn->0xe0 |
| 0x88 | functab: 13 absolute longs + ffffffff |
| 0x672 | `sys:s/mcpliberr.log`, `sys:devs/keymaps/` paths |
| 0xd9e+ | dep strings: dos/utility/asl/intuition/keymap.library + keymap.resource |
