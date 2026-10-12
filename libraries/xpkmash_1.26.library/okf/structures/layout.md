# Structures — xpkMASH 1.26

## XpkSubParams (as read by Pack/Unpack; a0 on entry)

| off | size | field | use |
|-----|------|-------|-----|
| 0x00 | 4 | xsp_InBuf | source |
| 0x04 | 4 | xsp_InLen | source length |
| 0x08 | 4 | xsp_OutBuf | dest |
| 0x10 | 4 | xsp_OutLen | written: packed size |
| 0x1c | 4 | xsp_Mode | `tries = 1 << (mode/10)` |
| 0x3c | 4 | xsp_Bound | overwritten: `outbuf + inlen - 10` |
| 0x40 | 4 | xsp_Tries | overwritten: `1 << (mode/10)` |

## Library data (dataSize 0x4a)

Std Library node + `exec@+34`, `seglist@+38`.

## Work allocations (`Sub[]` at libbase+dataSize, per PackChunk)

| slot | size | contents |
|------|------|----------|
| Sub+0 `alloc1` | always 0x10000 | chain ring: base `alloc1+0x8000`, element `sext16(pw)*2` — pointer-low-words <0x8000 use the upper 32KB, >=0x8000 wrap into the lower 32KB.  **Uninitialised** except `chain[in.w]=0xffff` — residual AllocMem garbage drives early chain walks (faithful). |
| Sub+1 `alloc2` | `512<<shift`, shift 8..4 (0x20000..0x2000, halved on AllocMem failure, 5 tries) | hash head table of `256<<shift` UWORDs; hash index `((b1<<shift)&0xff00) | b0`, all heads seeded with `in.w` at init (underwritten by 0x100 — `filldown` DBF +1). |

## Descriptor (XpksPackerInfo, -30)

XpkInfo block at file 0x558; xi_Version 0, xi_MaxPkInChunk
**0x100000** (V1.16: 0x0f0000), xi_MaxUnPkInChunk 0, mode-table
pointer + name "MASH" + longname "MASH V1.26, good packer" +
description "WindowSize: 32KB, 2 mixed streams Dynamic Buffer
Allocation" (V1.16 also had trailing " Nice CF").

## Mode table (packinit descriptor, single record)

| off | size | field | val |
|-----|------|-------|-----|
| +0  | 4 | xm_Next | 0 |
| +4  | 4 | xm_Upto | 100 |
| +8  | 4 | xm_Flags | 1 |
| +12 | 4 | xm_PackMemory | 0 |
| +16 | 4 | xm_UnpackMemory | 0 |
| +20 | 4 | xm_PackSpeed | **17** (V1.16: 18) |
| +24 | 4 | xm_UnpackSpeed | **400** (V1.16: 300) |
| +28 | 2 | xm_Ratio | **472** (V1.16: 480) |
| +30 | 2 | xm_ChunkSize | 0 |
| +32 | 12 | name | ` -->    \0` + 3 pad |
| +44 | 2 | tail | `7ff8` (V1.16: `ffff`) |

Built record is byte-exact vs the original.

## Codec tables (shared verbatim with V1.16)

- `runtab`: `0,10,110,1110,11110` direct runs 0-5;
  `rclass`: bases 6,8,14,30,...`0xffff-2` with (w+1)-bit excesses.
- `lclass`: len>=4 class bases 2,4,8,16,32,... (w+1)-bit excess.
- `distw`/`distor`: 8 dist classes, payload widths
  5,7,9,10,11,12,13,14 at cumulative bases
  0,0x20,0xa0,0x2a0,0x6a0,0xea0,0x1ea0,0x3ea0.
