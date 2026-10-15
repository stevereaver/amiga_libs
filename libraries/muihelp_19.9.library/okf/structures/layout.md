---
file: layout
---
# muihelp 19.9 layout

File 5224B. Header 0x3f3, no resident names, tablesize 3,
hunks 0..2, size specs 0x00000305 / 0x000001df / 0x40000006
longs.

- h0 CODE 0x305 longs = 3092B @file 0x28..0xc3b. RELOC32 tail
  @0xc3c, 3 groups: 14->h0 [0xb92,0xb28,0xb24,0xb20,0xb1c,
  0xb18,0xb14 (5 functab slots + pea target), 0xf8 (functab
  lea in init), 0x78 (extra ptr ->h0+0x6a2), 0x6c,0x68,0x64,
  0x5c,0x58 (RomTag fields)], 8->h1 [0x776,0x6c6,0x6b0,0x468,
  0x350,0x2a0,0x28c,0x26e — all `lea 0,a4` SAS/C a4 setups],
  1->h2 [0xa58 — `lea h2,a1` arg to intuition -270].
  END @0xcb8.
- h1 DATA 0x1df longs = 1916B @file 0xcc4..0x143f. NO relocs.
  END @0x1440.
- h2 DATA|0x40000000 (memory-flagged) 6 longs = 24B, body
  @file 0x144c..0x1463 = all zeros. END @0x1464.

## h0 CODE map

| off | content |
|-----|---------|
| 0x00 | reserved fn `moveq #0,d0; rts` (also vector -24) |
| 0x04 | "muihelp.library" |
| 0x14 | "$VER: muihelp.library 19.9 (12.02.97) ©1992-1997 Stefan Stuntz\r\n" |
| 0x56 | RomTag (below) |
| 0x70 | 2 zero longs; @0x78 relocated long ->h0+0x6a2 (a4-setup thunk); pad to 0x84 |
| 0x84 | dep name strings: dos/graphics/intuition/utility/muigfx/layers .library |
| 0xe4 | words 0x1b37,0x1b34 + 0 (build tags?) |
| 0xec | init routine (rt_Init target) |
| 0x17e/0x1dc/0x220 | expunge / open / close |
| 0x264..0x3d9 | a4-setup, openlibs, closelibs |
| 0x3dc/0x45c | draw helper / render loop |
| 0x6a2 | a4-setup thunk (ptr stored @h0+0x78) |
| 0x6be | dispose (vector -36) |
| 0x768 | create (vector -30) |
| 0xb14 | functab: 6 abs-longs [1dc,220,17e,0,768,6be] + 0xffffffff |
| 0xb30..0xc10 | SAS/C dispatcher stubs; h0+0xb9e = ret stub |

## RomTag @h0+0x56 (26B)

matchword 4afc, matchtag->h0+0x56, endskip=h0+0x70,
flags=0x00 (**not AUTOINIT** — rt_Init is a routine), ver 19,
type 9 NT_LIBRARY, pri 0, name->h0+0x04, idstring->h0+0x1a,
init->h0+0xec.

## init routine @h0+0xec (a0=seglist, reads *(4)=exec)

MakeLibrary(h0+0xb14, 0, 0, dSize=0x54, segList=0); fills
ln_Type=9, ln_Name->h0+4, lib_Flags=6 (CHANGED|SUMUSED),
ver 19, rev 9, lib_IdString->h0+0x14, seglist->lib+0x22,
InitSemaphore(lib+0x26); bsr h0+0x264 (a4-setup + execbase
->a4+0x760); on success AddLibrary + ret lib, else
FreeMem + ret 0.

## library data (dSize 0x54)

lib+0x22 seglist, lib+0x26 SignalSemaphore (46B) -> ends 0x54.
opencnt = lib+0x20 (standard). DELEXP = lib_Flags bit3.

## h1 DATA map (SAS/C a4 segment)

| off | content |
|-----|---------|
| 0x000 | packed blob #1: `00 49 00 3d` (73 x 61?) RLE-ish bytes, passed to MUIGfx -66 as a4+0 |
| 0x014 | packed blob #2 (a4+0x14 arg of same decode call) |
| 0x..757 | image data tail |
| 0x760 | ExecBase (written by setup) |
| 0x764 | IntuitionBase | 0x768 GfxBase | 0x76c DOSBase |
| 0x770 | UtilityBase | 0x774 MUIGfxBase | 0x778 LayersBase |

## h2 (flagged DATA, 24B zeros)

Referenced once: `lea h2,a1` at h0+0xa56 (reloc h0+0xa58),
arg to intuition -270 inside create — a zeroed 24-byte shared
block (allocated with a memory-type flag).
