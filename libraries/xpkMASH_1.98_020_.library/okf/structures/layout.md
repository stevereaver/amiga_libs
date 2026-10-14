---
type: Structure
title: xpkMASH_1.98(020) layout
---

# Hunk map (020 build, 2,796 bytes)

```
0x0000  HUNK_HEADER (0x3f3), no names, 1 hunk, first=last=0
0x0014  hunk size table: 0x292 (658 longs)
0x0018  HUNK_CODE (0x3e9), size 0x292 -> body at 0x20, 2,632 bytes
0x0a68  RELOC32 (0x3ec): 28 offsets, all hunk 0
0x0ae8  HUNK_END (0x3f2)
```

RELOC32 offsets (code-relative):
`6 a 12 16 1a | 56 5a 5e | 62 66 6a 6e 72 76 7a 7e 82 86 |
94 a6 | b6 ba be | d6 da de e2 ea`
= romtag ptrs (5) | inittab ptrs (3) | functab (10) |
datatab ptrs (2) | xpkinfo string ptrs (3) | msg ptrs (4) + modes ptr (1)

# Resident / init layout (code offsets)

```
0x0000  moveq #-1,d0; rts                (resident entry -> -1)
0x0004  RomTag: 4afc, matchtag, endskip=codeend, AUTOINIT v1
        NT_LIBRARY pri 0, name/idstr/init ptrs
0x001e  _libname  "xpkMASH.library\0"
0x002e  _idstr    " $VER: xpkMASH.library_020 V1.98\r\n\0\0"
0x0052  InitTable: dataSize=0x4a, ftab@0x62, dtab@0x8e, init@0x1b6
0x0062  functab: absolute longs -> entrypoints, 0xffffffff end
0x008e  InitStruct data table (InitDataTable encoding):
        a0 0c 09          byte 9  @ +0x0c  (inside ln_Name; harmless
                            debris -- overwritten by the +0x0a long)
        80 0a <libname>   long    @ +0x0a  ln_Name
        a0 0e 06          byte 6  @ +0x0e  lib_Flags = CHANGED|SUMUSED
        90 14 0001        word 1  @ +0x14  lib_Version
        90 16 0062        word 98 @ +0x16  lib_Revision
        80 18 <idstr>     long    @ +0x18  lib_IdString
        00 00             end
0x00ae  XpkSubLib info block (XpksPackerInfo result, d0)
        +00 w xpkver=1  +02 w libver=1  +04 w masterver=2  +06 w modesver=0
        +08 l short "Mashiner"   +0c l long "MASH.020 V1.98, good packer"
        +10 l desc "WindowSize: 32KB, 2 mixed streams  Dynamic Buffer Allocation"
        +14 l id 'MASH'          +18 l flags 0x8009
        +1c l maxpk 0x7ffff      +20 l minpk 0x28  +24 l defpk 0x10000
        +28 l 'Mashing' +2c l 'UnMashing' +30 l 'Mashed' +34 l 'UnMashed'
        +38 w defmode=100 (+3a pad) +3c l modes@0x18a
        +40..+57 reserved zeros
0x018a  mode record:
        +00 l next=0      +04 l upto=100      +08 l flags=1
        +0c l packmem=0x11000                 +10 l unpackmem=0
        +14 l packspeed=17 +18 l unpackspeed=400
        +1c w ratio=0x1d8 +1e w maxpacked=0   +20 text " -->    "
```

# Library base (positive area, dataSize 0x4a)

```
+0x00..+0x0d  struct Node (ln_Succ/Pred/Type/Pri/Name)
+0x0e  lib_Flags (InitStruct writes 6; Expunge sets bit3 = delexp)
+0x10  lib_NegSize = 60 (10 vectors * 6)
+0x12  lib_PosSize = 0x22+0x4a = 0x6c
+0x14  lib_Version=1    +0x16  lib_Revision=98
+0x18  lib_IdString
+0x20  lib_OpenCnt (word)
+0x22  exec base (stored by LibInit)
+0x26  seglist   (stored by LibInit)
```

# XpkSubParams use (a0 at vector entry)

```
+0x00 InBuf   +0x04 InLen   +0x08 OutBuf   +0x0c (unused)
+0x10 OutLen (out)          +0x1c Mode (100)
+0x34 sub-ptr (unused by 1.98 -- no PackFree state)
+0x3c out-bound = OutBuf + InLen - 10   (written by pack)
+0x40 tries    = 1 << (mode/10)         (written by pack)
```

Note the pack bound is `OutBuf + InLen - 10` -- OutBufLen is never
consulted; a stream that cannot beat the input by 11 bytes is a
failure (return -17).

# Work-buffer layout

Two engines behind one wire format ("2 mixed streams"):

- inlen < 0x10001 and `AllocMem(0x20010 + 2*inlen, 1)` succeeds:
  the V2.0-style gap-array engine.  One allocation, freed inline.
    wk+0        head[64K w] rolling-key table
    wk+0x20000  gap/link array, 2*inlen bytes of 6-byte match records
                are written over it
- else: `AllocMem(0x10000)` for the chain table, then a work alloc
  tried at 0x20000 halving through 5 attempts (0x20000,0x10000,
  0x8000,0x4000,0x2000) -- the V1.16-style hash-chain engine.
  Both frees happen before the return.

Alloc calls always use `jsr a6@(-198)` with d1=1 (MEMF_PUBLIC) and
FreeMem via `jsr a6@(-210)`.  PackChunk leaves no state in xsp.

# Code region map (020)

Everything from the resident entry through XpksPackerInfo is
BYTE-IDENTICAL to the 000 build (0x0000..0x355).  The builds diverge
at 0x356: the 2-byte fill between PackerInfo and the clear loop is
`0x001c` in the 000 and `0x4b90` (`chk.w (a0),d5` -- dead; both
builds enter the clear loop via `bsr.w $358`, so it never executes).
From there on the same code is emitted with 68020 encodings
(scaled-index addressing etc.); regions land at lower offsets.
Corresponding region pairs (offsets at region start):

| region | 000 | 020 |
|---|---|---|
| dead fill | 0x356 `001c` (2B) | 0x356 `4b90` (2B) |
| _clear + pass1 | 0x358..0x460 | 0x358..0x458 |
| dead | 0x460..0x462 | 0x458..0x45a |
| pass2 lazy matcher | 0x462..0x57a | 0x45a..0x566 |
| dead | 0x57a..0x580 (6B) | 0x566..0x570 (10B) |
| coreB chain engine | 0x580..0x612 | 0x570..0x602 |
| dead | 0x612..0x620 (14B) | 0x602..0x610 (14B) |
| coreA emit loop | 0x620..0x7c0 | 0x610..0x7b0 |
| emit tables | 0x7c0..0x830 | 0x7b0..0x820 |
| emit code | 0x830..0x8a2 | 0x820..0x892 |
| dead | 0x8a2..0x8aa | 0x892..0x89a |
| decoder | 0x8aa..0x9be | 0x89a..0x9aa |
| dead | 0x9be..0x9c0 | 0x9aa..0x9ac |
| decoder tables | 0x9c0..0xa5c | 0x9ac..0xa48 |

Body sizes: 000 = 0xa5c (2,652), 020 = 0xa48 (2,632) -> 20 bytes
shorter overall.  Note the pass2 dead fill is 10 bytes in the 020
vs 6 in the 000, which is why regions after it sit 0x10 lower, not
0x14.

```
0x1b6 LibInit     0x1c4 Open    0x1d2 Close   0x1e2 Expunge
0x220 ret0 stub   0x224 XpksPackChunk         0x32e ret0 stub
0x332 XpksUnpackChunk           0x34c XpksPackerInfo
0x356 dead fill (4b90)          0x358 _clear  (bsr.w $358)
0x396 pass1       0x450 _flush/pass2-end      0x570 coreB
0x610 coreA/emit  0x820 emit tail             0x89a decoder
0x7b0..0x820 emit tables        0x9ac..0xa48 decoder tables
```
