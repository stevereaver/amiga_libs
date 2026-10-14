# cyberlayers_40.8.library -- layout

## File

| off    | content |
|--------|---------|
| 0x0000 | hunk header: 0x3f3, 2 hunks, sizes {0x211, 0xa7} longs |
| 0x001c | hunk0 tag 0x3e9 + size; body @0x24 (2116 B) |
| 0x0868 | hunk0 relocs: tag 0x3f7 + u16 groups + pad + 0x3f2 |
| 0x089c | hunk1 tag 0x3e9 + size; body @0x8a4 (668 B) |
| 0x0b40 | 0x3f2 HUNK_END |

## hunk0 map

| off   | content |
|-------|---------|
| 0x00  | `moveq #-1,d0; rts` entry stub |
| 0x04  | RomTag (AUTOINIT, v40, pri 0); EndSkip->h1 end |
| 0x1e  | "cyberlayers.library" |
| 0x32  | idstr; then "layers.library"@0x78, "cybergraphics.library"@0x87, "graphics.library"@0x9d, "layersdummy.library"@0xae |
| 0xc2  | InitTable {dsize=0x76, ftab->0xd2, dtab->0xde, init->0xfe} |
| 0xd2  | word-mode functab {ffff,3e0,3ee,402,448,ffff} -> 0x4b2/0x4c0/0x4d4/0x51a |
| 0xde  | InitStruct datatab (name/ver=40/rev=8/idstr) |
| 0xfe  | initfn |
| 0x152 | _clone routine |
| 0x454 | _install routine |
| 0x48c | patch table {LVO.w, fn.l} x6 + 0 term |
| 0x4b2 | -6 Open |
| 0x4c0 | -12 Close |
| 0x4d4 | -18 Expunge |
| 0x51a | -24 stub |
| 0x51e | embedded CYBL block (ver 0x27), code @0x530 = layers -126 replacement |

## hunk1 map

| off   | content |
|-------|---------|
| 0x00  | CYBL blk0 hdr (ver 0x27); code @0x12 = layers -36 |
| 0x1c  | CYBL blk1 hdr; code @0x2e = layers -186 (+ shared trampoline tail) |
| 0xd2  | CYBL blk2 hdr; code @0xe4 = layers -60 |
| 0xf6  | CYBL blk3 hdr; code @0x108 = layers -66 |
| 0x11e | CYBL blk4 hdr; code @0x130 = layers -180 (also bsr target of -60/-66) |
| 0x26a | tail helper (rect compare: `cmpw` chains -> d0 0/1) |

## library structure (dsize 0x76 = 118 bytes)

| off | field |
|-----|-------|
| +34 | exec base |
| +38 | seglist |
| +42 | layers.library base |
| +46 | graphics.library base |
| +50 | own stub fn (h0+0x51a) |
| +54 | cybergraphics.library base |
