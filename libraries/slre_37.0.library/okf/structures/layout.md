---
file: layout
---
# slre 37.0 layout

File 5160B (0x1428). HUNK_HEADER: tablesize 4, hunks 0-3,
sizes [0x475, 0x44, 0x4, 0xf] longs — all declared==physical.

| hunk | tag  | file off | body        | tail |
|------|------|----------|-------------|------|
| 0    | CODE | 0x24     | 0x2c-0x1200 (0x11d4B) | RELOC32 @0x1200: ->h0 {6,a}, ->h1 {82,92}, ->h2 {1a}, ->h3 {5a,34,16,12}; END @0x124c |
| 1    | DATA | 0x1250   | 0x1258-0x1368 (0x110B) | RELOC32 @0x1368: ->h0 {4}; END @0x137c |
| 2    | DATA | 0x1380   | 0x1388-0x1398 (16B) | RELOC32 @0x1398: ->h0 {c}, ->h3 {4}; END @0x13b8 |
| 3    | CODE | 0x13bc   | 0x13c4-0x1400 (60B) | RELOC32 @0x1400: ->h0 {10,c,8,4,0}; END @0x1424 |

Resident @h0+4 (after `moveq #0,d0;rts` stub @h0+0):
matchtag->h0+4, endskip->h0+0x1e, flags 0x80 AUTOINIT,
ver 37 (0x25), type 9 NT_LIBRARY, pri 0; name->h3+0x18
"slre.library", id->h3+0x28 "slre.library 37.0",
init->h2+0. rt_Init therefore points across hunks into h2.

h2 body = InitTable: { dsize 0x154, functab->h3+0,
initData 0 (NULL), initfn->h0+0x20 }.

h3 body = functab: 5 absolute longs ->h0 {d0, 1fe, 268, 0,
10fc} + 0xffffffff term @+0x14; "slre.library" @+0x18;
"slre.library 37.0" @+0x28. (CODE hunk used purely as
data by the linker.)

h1 body = 268-byte regex support struct copied verbatim to
libbase+0x3c by init: +0 long 0, +4 char* ->h0+0x306
("^$().[]*+?|\\Sdbfnrtv", metachar/class-name table),
+8..0x107 256-byte character-class map (0x20 word-delim,
0x10, 0x84/0x81/0x01, 0x82/0x02 class bits), +0x10c long 0
(segment-relocate count, unused here).

initfn @h0+0x20 (D0=libbase, A0=seglist, A6=SysBase) fills
the header by hand: ln_Type=9, ln_Name, lib_Flags=6,
Version=37/Revision=0, IdString; private: +0x22 seglist,
+0x2e alloc'd seg-copy (0), +0x32 self ptr, +0x36 const
0x1e; then memcpy's h1 -> libbase+0x3c (268B) and, if
*(h1+0x10c)!=0, AllocMem's + copies a segment table.
