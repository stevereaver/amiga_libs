# Data layouts

## Amiga hunk (file format)

```
+0x00  0000_03f3  HUNK_HEADER
+0x04  0           (no resident names)
+0x08  0000_0001  hunk table size (longs)
+0x0c  0000_0000  first hunk = 0
+0x10  0000_0000  last hunk = 0
+0x14  0000_0277  hunk 0 size = 631 longs = 2524 bytes
+0x18  0000_03e9  HUNK_CODE
+0x1c  0000_0277  code size (longs)
+0x20  ... code body, 2524 bytes, ends file at 0x9f4
```

Code must begin `70 00 4e 75` (`moveq #0,d0; rts`) with `4a fc`
RomTag at code+4. No relocations (all code-internal refs are
PC-relative or offset-table based). No DATA/BSS hunks.

## Code map (offsets into the hunk body)

| range      | contents |
|------------|----------|
| 0x000      | entry stub `moveq #0,d0; rts` (null-vector target) |
| 0x004      | RomTag (rt_EndSkip = 0) |
| 0x068      | InitTable: dataSize 0x26, functab@0x98, datatab, LibInit@0xb0 |
| 0x098–0xb0 | functab: `-1`, 10 word offsets, `-1` |
| 0xb0–0xb7  | LibInit: `moveal d0,a1; movel a0,a1@(34); rts` |
| 0xb8       | LibOpen / LibClose / LibExpunge (Close falls into Expunge) |
| 0x116      | XpksPackFree |
| 0x132      | XpksPackerInfo (`lea 0x90c`) |
| 0x13a      | XpksPackChunk: alloc 226700, delta pass, table clears, `bsr 0x302` |
| 0x208–0x300| flush_lit subroutine (flag + backward literal copy + 2-bit count) |
| 0x302–0x710| pack core (byte-identical to NUKE 1.8's) |
| 0x712–0x7b9| tables: selector {0,0,4,10}; thresholds/nbtab/codetab/basetab/copytab |
| 0x7ba      | XpksUnpackChunk: `bsr 0x888` decode, delta post-pass, ret 0 |
| 0x888–0x90b| decode core (byte-identical to NUKE 1.8's) |
| 0x90c      | XpkInfo descriptor (88 bytes) |
| 0x964      | XpkMode "normal" |
| 0x98e–0x9dc| strings (NUL-separated, even-padded) |

## XpkSubParams (a0 on entry to pack/unpack)

| off | field |
|-----|-------|
| +0  | InBuf |
| +4  | InLen |
| +8  | OutBuf |
| +12 | OutBufLen |
| +16 | OutLen (pack writes result here via `xsp+8` indirection... no —
        directly `movel d0,a5@(16)` in the wrapper) |
| +52 | Sub[0] = cached workspace pointer |

## Workspace (a4 in the core), AllocMem(0x3758c = 226700, MEMF_ANY)

| off      | field |
|----------|-------|
| +0       | src pointer = **work+92** (the delta buffer) |
| +4       | dst = OutBuf |
| +8       | tab1 = work+0x758c — pair→pos heads, 64K words |
| +12      | tab2 = work+0x2758c — pos→prev chain, 32K words |
| +16      | outcur — next stream slot |
| +20      | litptr — literal write ptr (grows **backward** from
             dst+sext(outmax)) |
| +24      | srcend = delta + inlen |
| +28      | tab2 lazy-clear frontier |
| +32 (w)  | inlen (word!) |
| +34 (w)  | outmax = OutBufLen-4 (word!) |
| +36 (w)  | lastpos = inlen-1 |
| +38 (w)  | litstart |
| +40 (s)  | litcnt-1 (init -1) |
| +42 (w)  | window = 0x6a8f |
| +44..+63 | ctr1..4 (words) + acc1..4 |
| +64..+79 | ptr1..4 (pending stream slots; start = +80 scratch) |
| +80..+91 | scratch — first flush of each stream lands here |
| +92 ..   | delta buffer, 0x7530 bytes (delta[i] = in[i]-in[i-1]) |
| +0x758c  | tab1 (0x20000 bytes) |
| +0x2758c | tab2 (0x10000 bytes) |

Delta buf + tab1 + tab2: 0x7530 + 0x20000 + 0x10000 = 0x37530;
+92 header = 0x3758c total. tab1/tab2 are re-cleared on **every**
PackChunk call (2×8192 longwords), not just after alloc.

## XpkInfo @ code+0x90c (88 bytes)

```
01 01 02 00 | Name→"DUKE" | LongName→"Duke V1.8"
| Desc→"NUKE with a delta preprocessor" | ID 'DUKE' | flags 9
| MaxPkInChunk 0x7530 | MinPkInChunk 0 | DefPkInChunk 0x7530
| "Duking" | "Unduking" | "Duked" | "Unduked"
| DefMode 100 | pad | ModeDesc→0x964 | 6 reserved longs
```

XpkMode @ 0x964: Next=0, Upto=100, Flags=1, PackMemory=0x3758c,
UnpackMemory=0, PackSpeed=0x27, UnpackSpeed=0x15e, Ratio=0x143,
ChunkSize=0, "normal".
