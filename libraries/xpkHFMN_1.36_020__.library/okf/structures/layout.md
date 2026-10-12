# xpkHFMN 1.36 (020+) — structures & layout

## Resident module (single hunk)

| off | field |
|-----|-------|
| 0x000 | `moveq #-1,d0; rts` entry stub |
| 0x004 | RomTag: RTC_MATCHWORD, MatchTag=&rt, EndSkip, RTF_AUTOINIT, ver 1, NT_LIBRARY, pri 0 |
| 0x01e | name "xpkHFMN.library" |
| 0x02e | id `$VER: xpkHFMN V1.36 (Tue Jun 13 17:55:56 1995)\r\n` + " Martin Hauner 68020+ Version" |
| 0x088 | InitTable: dataSize **0x2a**, functab 0x98, datatab 0xc4, initfn 0xe4 |
| 0x0e4 | LibInit: `movem a4/a5; a5=d0; a6@(34)=seglist; lea pc@(desc),a4; a6@(38)=a4` |

InitTable dataSize 0x2a = 42 = Library(34) + seglist@34 + xpkdesc@38.
datatab is the a0/e0/90/80 command stream: ln_Type=9, ln_Name, lib_Flags=6,
version 1, revision 36, idstring.

## XpkInfo descriptor (at 0x668, pointer stored at base+38)

```
00 01 00 01 00 02 00 00        ver=1 libver=1 masterver=2 modesver=0
00 00 06 c0   -> "HFMN"        (xi_Name)
00 00 06 c5   -> "dyn. Huffman.020+ Version 1.36 "  (xi_LongName)
00 00 06 e5   -> "fast dynamic Huffman compression/decompression."
48 46 4d 4e   'HFMN'           (xi_ID)
00 00 00 09   xi_Flags = 9
00 00 ff ff   xi_MaxPkInChunk = 0xffff
00 00 00 0c   xi_MinPkInChunk = 12
00 00 ff ff   xi_DefPkInChunk = 0xffff
00 00 07 15 -> "packing"       00 00 07 1d -> "unpacking"
00 00 07 27 -> "packed"        00 00 07 2e -> "unpacked"
00 00 00 00   xi_DefMode = 0, pad
00 00 07 38 -> XpkMode
6 x long      xi_Reserved = 0
```

## XpkMode @0x738 — " normal "

| field | value |
|-------|-------|
| xm_Next | 0 |
| xm_Upto | 100 |
| xm_Flags | 0 |
| xm_PackMemory | 0x1a0a (6666) |
| xm_UnpackMemory | 0x19fa (6650) |
| xm_PackSpeed | 0x103 (259) |
| xm_UnpackSpeed | 0xd1 (209) |
| xm_Ratio | 0xf7 (247) |
| xm_ChunkSize | 0x3f (63) |
| xm_Description[10] | `" normal "` + 2 NULs |

## Pack workmem (per-call AllocMem 0x1a0a, MEMF_CLEAR)

| off | field |
|-----|-------|
| +0x0002 | u16 freq[512] ([0..255] syms, [0x100+n] internal nodes) |
| +0x0402 | u16 heap[257] (1-based min-heap) |
| +0x0604 | s16 parent[512] (sign = side: + parent = '1' edge) |
| +0x0a06 | u16 child[512*2] (id*4: +0 = '0' child, +2 = '1' child) |
| +0x120a | u32 code[256] |
| +0x160a | u32 len[256] |

## Unpack workmem (per-call AllocMem 0x19fa, MEMF_CLEAR)

Generated threaded decoder is written at +0x13fa; the low area holds
the node/build stack. Reconstruction models the *semantics* (trie +
1024-entry 10-bit fast table, deep-code walk) rather than emitting
m68k opcodes.
