---
type: Structure
title: xpkNUKE_1.7 layouts
timestamp: 2026-10-14T00:00:00Z
---

# Hunk map (file layout)

```
file+0x00  HUNK_HEADER: 3f3, namelen=0, nhunks=2, first=0, last=1,
           sizes = { 0x27d, 0x21 }
file+0x1c  HUNK_CODE (3e9), size 0x27d longs
file+0x24  hunk0 body, 0x9f4 bytes (ends at 0xa18)
file+0xa18 HUNK_RELOC32 (3ec): {21 -> hunk0}, {1 -> hunk1}, 0
file+0xa88 HUNK_END (3f2)
file+0xa8c HUNK_DATA (3ea), size 0x21 longs
file+0xa94 hunk1 body, 0x84 bytes (ends at 0xb18)
file+0xb18 HUNK_RELOC32: {7 -> hunk0}, {1 -> hunk1}, 0
file+0xb4c HUNK_END; file size 0xb50 = 2900
```

The one hunk0->hunk1 reloc is the `lea` operand inside
XpksPackerInfo (descriptor lives in hunk 1).  The 7 hunk1->hunk0
relocs are the string pointers inside the XpkInfo (xi_Name etc.);
the 1 hunk1->hunk1 reloc is xi_ModeDesc -> data+0.

# Code hunk map

```
0x000  _start stub: moveq #-1,d0 / rts
0x004  RomTag: 4afc, MatchTag=4, EndSkip=0x106, Flags=0x80,
       Version=1, Type=9, Pri=0, Name=0x108, IdString=0x118,
       Init=0x1e
0x01e  InitTable: DataSize=0x22, FuncTab=0x2e, DataTab=0x5a,
       InitFn=0x7e
0x02e  functab: 10 absolute longs + ffffffff
0x05a  InitStruct datatab (type/name/flags/ver/rev/idstr)
0x07a  seglist slot (data, runtime)
0x07e  LibInit
0x09e/0x0ac/0x0c0  Open / Close / Expunge
0x104  -24 null stub (rts at 0x106 = EndSkip)
0x108  "xpkNUKE.library\0"
0x118  "xpkNUKE 1.7 (06.06.1997)\r\n\0"
0x134  shared null stub: InitFn + -48/-60 vectors
0x138  seltab_138 (4 words: len-class -> class-table selector)
0x140  clstab: 4 x {16 base words,16 nbits,32 nib code} region
       (offsets reused by pack emit at 0x462/0x46c and decode)
0x160..0x19f decoder helper tables (copy counts / 2-bit codes)
0x200  flush_lit
0x2fa  pack_core
0x60e  pack_init; 0x696 pack_finish; 0x6fa pack_tail
0x73c  unpack_core (jmp pc@(tab,d0:w) dispatch)
0x848  XpksPackerInfo; 0x852..0x8b5 descriptor strings
0x8b6  XpksPackFree; 0x902 pack_alloc; 0x952 XpksPackChunk;
0x9c6  XpksUnpackChunk; 0x9e8 backward memset; 0x9f4 end
```

# Data hunk map (hunk1, 0x84 bytes)

```
+0x00  XpkMode "normal":
       +00 xm_Next = 0
       +04 xm_Upto = 100
       +08 xm_Flags = 1
       +0c xm_PackMemory = 0x3005c
       +10 xm_UnpackMemory = 0
       +14 xm_PackSpeed = 0x24
       +18 xm_UnpackSpeed = 0x276
       +1c xm_Ratio = 0x1c6 (word), xm_ChunkSize = 0 (word)
       +20 "normal\0"
+0x2a  XpkInfo (returned by XpksPackerInfo):
       +00 xi_XpkInfoVersion=1, xi_LibVersion=1 (words)
       +04 xi_MasterVersion=0, xi_ModesVersion=1 (words)
       +08 xi_Name     -> code+0x852 "NUKE"
       +0c xi_LongName -> code+0x858 "Nuke"
       +10 xi_Description -> code+0x85e
            "A relatively efficient packer that unpacks very quickly"
       +14 xi_ID = 'NUKE'
       +18 xi_Flags = 9
       +1c xi_MaxPkInChunk = 0x7530, +20 Min = 10, +24 Def = 0x7530
       +28 xi_PackMsg   -> code+0x896 "Nuking"
       +2c xi_UnpackMsg -> code+0x89e "Unnuking"
       +30 xi_PackedMsg -> code+0x8a8 "Nuked"
       +34 xi_UnpackedMsg -> code+0x8ae "Unnuked"
       +38 xi_DefMode = 0x32 (word), xi_Pad = 0 (word)
       +3c xi_ModeDesc -> data+0
       +40..+57 xi_Reserved[6] = 0
```

# Library base

Standard NT_LIBRARY base (negsize 60, possize 68 = 34 + datasz 0x22).
**No extension fields** — the seglist is NOT at lib+0x38; it lives
in the code-hunk slot at code+0x7a.

# Pack workspace — three separate blocks at xsp_Sub[0]

92-byte header (MEMF_CLEAR) + tab1 0x20000 + tab2 0x10000
(MEMF_NONE; cleared by the wrapper's memset each call):

| off  | size | field | notes |
|------|------|-------|-------|
| +0   | 4    | src     | input base (a5) |
| +4   | 4    | dst     | output base |
| +8   | 4    | tab1    | pair->pos head, 64K words |
| +12  | 4    | tab2    | pos->prev chain, 32K words |
| +16  | 4    | outcur  | next stream-slot write position |
| +20  | 4    | litptr  | literal write ptr (descends) |
| +24  | 4    | srcend  | src + (SHORT)inlen (addaw!) |
| +28  | 4    | t2front | tab2 lazy-clear frontier |
| +32  | 2    | inlen   | xsp_InLen low word |
| +34  | 2    | outmax  | (OutBufLen-4) low word |
| +36  | 2    | lastpos | inlen - 1 |
| +38  | 2    | litstart| first pending literal index |
| +40  | 2    | litcnt  | pending literals - 1 |
| +42  | 2    | window  | 0x6a8f hash-chain window |
| +44  | 8    | ctr1-4  | bit counters, streams 1..4 |
| +52  | 12   | acc1-4  | accumulators (acc3 rorl, acc4 asll\|v) |
| +64  | 16   | ptr1-4  | pending-slot writers, seeded &scratch |
| +80  | 12   | scratch | staging until first real slot |

# XpkSubParams fields used

`xsp_InBuf/InLen/OutBuf/OutBufLen` read; `xsp_OutLen` (xsp+16)
written by both pack (raw pack_core result, -1 on overflow) and
unpack; `xsp_Sub[0]` (xsp+52) = workmem cache, cleared by PackFree.
