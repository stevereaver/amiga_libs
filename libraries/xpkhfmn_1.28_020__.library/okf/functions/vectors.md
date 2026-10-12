# xpkHFMN 1.28 — vectors

LONG-offset functab at code+0x9c (10 entries + `-1` terminator),
unlike the 1.4 sibling's signed word-offset table.

| LVO | addr | role |
|-----|------|------|
| -6  | 0x58e | LibOpen — `addq.w #1,32(a6); bclr #3,14(a6); move.l a6,d0` |
| -12 | 0x59c | LibClose — `d0=0; --OpenCnt; if 0 && DELEXP -> expunge` |
| -18 | 0x5b0 | LibExpunge — unconditional inline-unlink + FreeMem, returns seglist (NO OpenCnt check) |
| -24 | 0x5e2 | Reserved — `moveq #0,d0; rts` |
| -30 | 0x100 | XpksPackerInfo — `move.l 38(a6),d0` (descriptor ptr stored by init) |
| -36 | 0x106 | XpksPackChunk — 020+ Huffman packer |
| -42 | 0x3d0 | stub `rts` (PackFree equivalent; workmem is alloc'd per-call) |
| -48 | 0x3d2 | stub `rts` (PackReset equivalent) |
| -54 | 0x3d4 | XpksUnpackChunk — code-generating decoder |
| -60 | 0x58c | stub `rts` (UnpackFree equivalent) |

## Init (code+0xe8)

`movem.l a4-a5,-(sp); movea.l d0,a5; move.l a0,34(a5); lea desc(pc),a4; move.l a4,38(a5); movem.l (sp)+,a4-a5; rts`

Stores seglist at lib+34 and the XPK descriptor pointer at lib+38
(dataSize = 0x2a = Library 34 + 4 + 4).

## Exec calls used

- AllocMem (-198): pack `0x1a0a`, unpack `0x19fa`, flags `0x10000` (MEMF_CLEAR)
- FreeMem (-210): same sizes
- CacheClearU (-636): called iff `AttnFlags bit2 (68030)` AND `exec lib_Version >= 36`
- Unlink in Expunge is INLINED (`2059 2251 2288 21490004`), no Remove() call.

## CPU gates

- PackChunk requires `AttnFlags bit1` (AFF_68020) else returns -21.
- UnpackChunk runs on any CPU but only cache-clears on 030+OS2.0.

## Return codes

- -21 unsupported CPU, -7 AllocMem failure, -17 OutLen > xsp_OutBufLen,
  0 success. OutLen = 2 + treeBytes + 5 + dataBits/8.
