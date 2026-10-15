---
type: Structures
title: diskfont 1.3 (WB1.0) layout
---

# Layout

## Hunks (13, tablesize=13 first=0 last=12; RELOC32 tails only)

| h | tag  | size  | contents |
|---|------|-------|----------|
| 0 | CODE | 580B  | resident@+4, name/idstr, rt_Init@+0x4c,
   |      |       | libInit@+0x7a, 'dos.library'@+0x112,
   |      |       | 'graphics.library'@+0x11e, datatab@+0x130,
   |      |       | functab@+0x158, Expunge@+0x174, null@+0x21c,
   |      |       | Open@+0x21e, Close@+0x22c |
| 1 | CODE | 32B   | vector trampolines: +0 AvailFonts->h3+0,
   |    |      |       +0x12 OpenDiskFont->h5+0xe0 |
| 2 | DATA | 16B   | globals: +0 libself, +4 ExecBase, +8 DOSBase,
   |    |      |       +0xc GfxBase (filled by libInit) |
| 3 | CODE | 636B  | AvailFonts implementation |
| 4 | DATA | 16B   | 'FONTS:'@+0 (pad to +8), '.font'@+8 |
| 5 | CODE | 852B  | +0 weigh helper, +0xe0 OpenDiskFont impl |
| 6 | DATA | 136B  | 'FONTS:'@+0 + penalty tables @+8/+0x28/
   |    |      |        +0x48/+0x68 (4 x 8 longs) |
| 7 | CODE | 236B  | string helpers (see vectors.md) |
| 8 | DATA | 0B    | EMPTY hunk (declared, no body) |
| 9 | CODE | 0B    | EMPTY hunk |
|10 | CODE | 240B  | dos.library thunk table |
|11 | CODE | 104B  | exec.library thunk table |
|12 | CODE | 60B   | graphics.library thunk table |

## Library instance (dsize 0x38 = LIB_SIZE 0x22 + 0x16 private)

- +0x00..0x21  struct Library via InitStruct + MakeLibrary
- +0x22  LONG  seglist (rt_Init's incoming a0)
- +0x26  WORD  private open count (NOT lib_OpenCnt@+0x20)
- +0x28  WORD  font count (nodes in the list below)
- +0x2a  LIST  private disk-font list (12B head/tail/tailpred);
         InitStruct sets lh_Type@+0x36 = 0x0c (NT_FONT)

## InitStruct datatab (h0+0x130, 38B)

e000 0008 0900  INITBYTE ln_Type@8    = 9 (NT_LIBRARY)
c000 000a <h0+0x1e> INITLONG ln_Name  = 'diskfont.library'
e000 000e 0600  INITBYTE lib_Flags@0xe = 6 (SUMUSED|CHANGED)
d000 0014 0001  INITWORD lib_Version   = 1
d000 0016 0003  INITWORD lib_Revision  = 3
e000 0036 0c00  INITBYTE lib+0x36      = 0x0c (list lh_Type)
0000            END.  lib_IdString (+0x18) left NULL.

## .font descriptor file format (as consumed)

4B header: w fch_FileID must be 0x0f00, w fch_NumEntries;
then N records of 260B = FontContents { UBYTE fc_FileName[256],
UWORD fc_YSize@+256, UBYTE fc_Style@+258, UBYTE fc_Flags@+259 }.

## Loaded font node (inside LoadSeg'd segment, node = seg+8)

+0x12 seglist BPTR (UnLoadSeg'd on expunge), +0x16 basename
(strcpy'd), +0x36 embedded TextFont (returned by OpenDiskFont,
passed to AddFont -480), +0x4d flags (bit 1 set), +0x54 WORD
accessors/refcount.
