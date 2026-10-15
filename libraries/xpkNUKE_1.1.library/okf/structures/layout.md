---
type: Structure
title: xpkNUKE 1.1 layouts
timestamp: 2026-10-15T00:00:00Z
---

# Hunk map (file layout)

```
file+0x00  HUNK_HEADER: 3f3, namelen=0, nhunks=2, first=0, last=1,
           sizes = { 0x2bd, 0x50 }
file+0x1c  HUNK_CODE (3e9), size 0x2bd longs
file+0x24  hunk0 body, 0xaf4 bytes (ends at file 0xb18)
file+0xb18 HUNK_RELOC32: {16 -> hunk0}, {2 -> hunk1}, 0
file+0xb78 HUNK_END
file+0xb7c HUNK_DATA (3ea), size 0x50 longs
file+0xb84 hunk1 body, 0x140 bytes (ends at 0xcc4)
file+0xcc4 HUNK_RELOC32: {2 -> hunk0}, 0
file+0xcdc HUNK_END; file size 0xce0 = 3296
```

# Code hunk map

```
0x000  entry stub / -24 vector: moveq #0,d0; rts
0x004  RomTag: 4afc, MatchTag=4, EndSkip=0x1e, Flags=0x80,
       Version=1, Type=9(NT_LIBRARY), Pri=0, Name=0xad0,
       IdString=0xae0, Init->data+4
0x01e  pad word 0000
0x020  InitFn (data-hunk copy + self-reloc + jsr 0xaf0 noop)
0x0d2  Open    0x0ee  Close    0x118  Expunge
0x17c  XpksPackerInfo (lea a6@(0x3a),a4; lea a4@(0xc4),a0)
0x18c  PackFree (frees ctx+8 0x20000, ctx+0xc 0x10000, ctx 84)
0x1f4  table clear (ctx in a0)
0x244  PackChunk      0x308  -48 stub    0x31a  UnpackChunk
0x35c  -60 stub
0x36c..0x433  pack/unpack offset-class + copy-count tables
0x434  delayed-slot bit writer
0x52e  pack core      0x862  ctx init    0x8ec  final flush
0x950  tail copy/pad  0x992  unpack core
0xaa2  pad 0000
0xaa4  functab: 10 abs longs + ffffffff
0xad0  "xpkNUKE.library\0"   0xae0  "Version 1.0\0"
0xaec  rts (expunge hook)    0xaf0  rts (init tail)   0xaf2 pad
```

# Data hunk map (copied verbatim to lib+0x3a by InitFn)

```
+0x00 0000 0000
+0x04 InitTable: dataSize=0x156 funcTab=code+0xaa4 dataTab=0
      initFn=code+0x20            (also copied, unused there)
+0x14 "$VER: NUKE 1.1 (Nov  2 1992)\0\0"
+0x32 XpkMode "normal":
      +00 xm_Next=0  +04 xm_Upto=100  +08 xm_Flags=1
      +0c xm_PackMemory=0x30054  +10 xm_UnpackMemory=0
      +14 xm_PackSpeed=0x24  +18 xm_UnpackSpeed=0x276
      +1c xm_Ratio=0x1c4(w)  +1e xm_ChunkSize=0(w)
      +20 "normal\0" (+0x52)
+0x5c "NUKE\0"  +0x62 "Nuke 1.0\0"
+0x6c "A relatively efficient packer that unpacks very quickly\0"
+0xa4 "Nuking\0" +0xac "Unnuking\0" +0xb6 "Nuked\0" +0xbc "Unnuked\0"
+0xc4 XpkInfo (XpksPackerInfo returns lib+0xfe = block+0xc4):
      +00 ver=1 +02 libver=1 (w)  +04 master=0 +06 modesv=1 (w)
      +08 Name->+0x5c  +0c LongName->+0x62  +10 Desc->+0x6c
      +14 ID 'NUKE'  +18 Flags=9
      +1c MaxPkInChunk=0x7530  +20 MinPkInChunk=0xa
      +24 DefPkInChunk=0x7530
      +28..+34 msg ptrs -> +0xa4/+0xac/+0xb6/+0xbc
      +38 DefMode=0x32(w)  +3a pad
      +3c ModeDesc -> +0x32
+0x11c count=8 -> +0x120 offset table {0x100,0xf8,0xf4,0xf0,0xec,
      0xd4,0xd0,0xcc}  (block-relative ptr slots to fix to lib+0x3a)
```

# Library base

Standard NT_LIBRARY base, negsize 60 (10 vectors), possize 376
(34 + dataSize 0x156).  lib+0x22 (34) = seglist.
lib+0x3a..+0x155 = private copy of the data hunk (descriptors and
strings live in the lib image, not in a loaded segment).

# Pack workspace — three allocations at xsp_Sub[0]

ctx 84B (MEMF_CLEAR|MEMF_PUBLIC), tab1 0x20000B, tab2 0x10000B
(both plain MEMF; explicitly memset by routine 0x1f4 every pack call):

| off  | size | field |
|------|------|-------|
| +0   | 4    | src = InBuf |
| +4   | 4    | dst = OutBuf |
| +8   | 4    | tab1: pair->pos hash heads, 64K words |
| +12  | 4    | tab2: pos->prev chain, 32K words |
| +16  | 4    | outcur: next free stream-slot write pos |
| +20  | 4    | litptr: literal write ptr (descends from dst+outmax) |
| +24  | 4    | srcend = src + inlen |
| +28  | 4    | t2front: tab2 lazy-clear frontier |
| +32  | 2    | inlen (xsp_InLen low word — truncated!) |
| +34  | 2    | outmax = OutBufLen-4 low word |
| +36  | 2    | lastpos = inlen-1 |
| +38  | 2    | litstart |
| +40  | 2    | litcnt (init -1) |
| +42  | 2    | window = 0x2aa0 (max chain walk) |
| +44..51 | 4x2 | ctr1..ctr4 bit counters |
| +52..63 | 2+2+4+4 | acc1,acc2 (w); acc3,acc4 (l) |
| +64..79 | 4x4 | ptr1..ptr4 delayed write slots, seeded &ctx[80] |
| +80..83 | 4 | scratch (absorbs the seeding writes) |
