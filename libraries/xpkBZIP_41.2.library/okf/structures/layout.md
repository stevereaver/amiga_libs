# xpkBZIP — structures

## Hunk map (original)

CODE hunk0 (0x508): +0 entry stub (returns -1), +0xe LibInit,
+0x46 LibOpen, +0x5e LibClose, +0x80 LibExpunge, +0xcc null,
+0xdc initppc, +0x112 "ppc.library", +0x11e exitppc,
+0x144 PackerInfo, +0x152 strings ("BZIP", "BZIP (PPC) 41.2",
description, msgs, ELF path @+0x1e6), +0x1fc PackChunk,
+0x32e PackFree, +0x37c null, +0x38a UnpackChunk, +0x4b6
UnpackFree.

DATA hunk1 (0x314):

| off   | content                                        |
|-------|------------------------------------------------|
| +0x00 | InitTable {0x32, funcs→+0x10, data→+0xec,      |
|       |   init→h0+0xe} — absolute-pointer form          |
| +0x10 | functab: 10 absolute longs + -1                 |
| +0x3c | globals (zeros): +60 lib, +120 SysBase,         |
|       |   +124 ppcbase                                  |
| +0x84 | "xpkBZIP.library"                               |
| +0x94 | "$VER: xpkBZIP.library 41.2 (18.08.97)          |
|       |   © by André Osterhues"                         |
| +0xd0 | exec Resident: 4afc, →self, →+0x310,           |
|       |   flags 0x80 ver41 type9 pri2, name, idstr,     |
|       |   rt_Init→+0x00, 2-byte pad                     |
| +0xec | datatab (e0/d0 24-bit + 80 8-bit forms)         |
| +0x114| 10 XpkMode records × 42 B                       |
| +0x2b8| XpkInfo descriptor (88 B)                       |
| +0x310| end (4 zero pad)                                |

## Lib private data (dataSize 0x32)

+34 seglist, +38 SysBase, +42 ppcbase.

## InitStruct datatab (+0xec)

    e0 0000 08 09 00    byte@8  = 9 (NT_LIBRARY)
    80 0a ->libname     long@10 = name
    e0 0000 0e 06 00    byte@14 = 6 (flags)
    d0 0000 14 0029     word@20 = 41
    d0 0000 16 0002     word@22 = 2
    80 18 ->verstr      long@24 = idstring
    00000000            terminator

## XpkMode record (42 B)

| off | field                                        |
|-----|----------------------------------------------|
| +0  | xm_Next → PREVIOUS record (0 = chain end)    |
| +4  | xm_Upto (10..100)                            |
| +8  | flags (0)                                    |
| +0xc| xm_PackMemory                                |
| +0x10| xm_UnpackMemory                             |
| +0x14| xm_PackSpeed                                |
| +0x18| xm_UnpackSpeed                              |
| +0x1c| W xm_Ratio + W xm_ChunkSize (KB block size) |
| +0x20| name[8] inline, unterminated (" 100 K"…)    |
| +0x28| 2-byte pad                                   |

10 records ordered "1000 K" → " 100 K" in memory; xi_ModeDesc
anchors the chain at the LAST record so the xpk-visible
order is ascending (100 K first).  Values:

| mode | upto | packmem | unpackmem | ps | us | rat | cs  |
|------|------|---------|-----------|----|----|-----|-----|
| 1000 K | 100 | 0x810004 | 0x5dc000 | 43 | 168 | 663 | 1000 |
|  900 K |  90 | 0x748004 | 0x546000 | 46 | 166 | 643 |  900 |
|  800 K |  80 | 0x680004 | 0x4b0000 | 49 | 164 | 610 |  800 |
|  700 K |  70 | 0x5b8004 | 0x41a000 | 51 | 166 | 576 |  700 |
|  600 K |  60 | 0x4f0004 | 0x384000 | 54 | 164 | 548 |  600 |
|  500 K |  50 | 0x428004 | 0x2ee000 | 55 | 161 | 536 |  500 |
|  400 K |  40 | 0x360004 | 0x258000 | 59 | 168 | 532 |  400 |
|  300 K |  30 | 0x298004 | 0x1c2000 | 61 | 173 | 529 |  300 |
|  200 K |  20 | 0x1d0004 | 0x12c000 | 65 | 173 | 525 |  200 |
|  100 K |  10 | 0x108004 | 0x096000 | 72 | 187 | 515 |  100 |

## XpkInfo (+0x2b8, 88 B)

ver 1.1, master 2, modes 1; name→"BZIP", long→"BZIP (PPC)
41.2", desc→"BZIP, a block-sorting file compressor
(requires a PowerPC processor)"; ID 'BZIP'; flags 0x8409;
MaxPkIn 0xfa000, MinPkIn 0x64, MaxPkOut 0xfa000;
msgs → "Compressing"/"Decompressing"/"Compressed"/
"Decompressed"; DefMode 100; ModeDesc → last record.
