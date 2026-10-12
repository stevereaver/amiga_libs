# Structures / memory layout

## XpkSubParams (as used)

| off | field |
|-----|-------|
| +0  | in buffer ptr |
| +4  | in length |
| +8  | out buffer ptr |
| +16 | out length (written by packer, read by decoder as stop) |
| +28 | mode (word compare) |
| +52 | `Sub[0]` workmem ptr (points at alloc+4; alloc[0] = alloc size) |

## Work memory (alloc `(1<<bits)*4 + 0x40004`, flag 0)

```
alloc+0        alloc size (for PackFree)
Sub[0] = alloc+4
Sub+0x00000    hash head table: 65536 ULONGs
               index = (b0<<8) | ((b1+b2)&0xff); value = in-pointer or 0
Sub+0x40000    chain ring: (1<<bits) ULONGs
               index = pointer & (1<<bits)-1; value = previous head
```

The original reaches `head[h]` as `a5 + h*4 - 0x40000` where
`a5 = Sub+0x40000`, using a `moveq #-1` seed so the hash index is
negative — equivalent to `head = (ULONG*)Sub`.

The chain slot is `(address) & mask`, i.e. a ring over pointer values —
positions `1<<bits` apart alias (intended LZSS window behaviour).

## Hash clear

`XpksPackReset` zeroes exactly `Sub[0..0x40000)` (the head table)
via 4x unrolled `movem` writes of 13 zeroed registers from
`a6 = Sub+0x40000` downward: `64 + 1260*52 = 0x40000` bytes.
The chain ring is *not* cleared — stale links are only reached
through freshly written heads, so they are never dereferenced.

## XpkInfo descriptor @0x4a2

```
.w 1,2,2,0          xi_XpkInfoVersion/LibVersion/MasterVersion/ModesVersion
.l ->"LZStreamer", ->"BSI Bitstream Packer V2.1",
.l ->"LZSS family with 2-13 bits window"
.l 'LZBS'           xi_ID
.l 0x8009           xi_Flags
.l 0x7fffffff       xi_MaxPkInChunk
.l 0                xi_MinPkInChunk
.l 0x00050000       xi_DefPkInChunk
.l ->"BSsss...", ->"UnnnBS...", ->"Oh god, It is done!", ->"Hehe, fast hew."
.w 0x64, 0          xi_DefMode=100, pad
.l -> modes         xi_ModeDesc
.l 0 x6             reserved
```

## Mode records — 12 x 42 bytes, inline name[10]

Layout: `.l next, upto, flags=1, packmem, unpackmem=0, pspeed, uspeed`
`.w ratio` `.w 0` `.ascii name[10]`.

| name | upto | packmem | ps | us | ratio |
|------|------|---------|----|----|-------|
| 2 bits | 1 | 0x40014 | 33 | 54 | 0x31 |
| 3 bits | 10 | 0x40024 | 33 | 53 | 0x55 |
| 4 bits | 20 | 0x40044 | 33 | 53 | 0x62 |
| 5 bits | 30 | 0x40084 | 34 | 53 | 0x8b |
| 6 bits | 40 | 0x40104 | 35 | 54 | 0xbc |
| 7 bits | 50 | 0x40204 | 36 | 56 | 0xeb |
| 8 bits | 60 | 0x40404 | 36 | 58 | 0x10c |
| 9 bits | 70 | 0x40804 | 36 | 60 | 0x126 |
| 10 bits | 80 | 0x41004 | 35 | 62 | 0x13a |
| 11 bits | 90 | 0x42004 | 33 | 64 | 0x148 |
| 12 bits | 98 | 0x44004 | 30 | 65 | 0x14f |
| 13 bits | 100 | 0x48004 | 26 | 67 | 0x150 |

`upto` matches the packer's mode->bits thresholds exactly;
`packmem` = `0x40004 + (1<<bits)*4` = the real allocation.
