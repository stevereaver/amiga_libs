# xpkBLZW 3.4 — Structures

## xpkPack param block (a0/a3 in the vectors)

| off | field | use |
|-----|-------|-----|
| 0x00 | InBuf  | packed input (unpack) / raw input (pack) |
| 0x04 | InLen  | input length |
| 0x08 | OutBuf | output buffer |
| 0x0c | OutBufLen | (not used by this sublib) |
| 0x10 | OutLen | packed length written back by packer |
| 0x1c | Mode   | compression mode 0..100 |
| 0x34 | work   | cached work buffer ptr (owned by sublib) |
| 0x38 | worksize | its allocated size |

## XpkInfo descriptor (file off 0x4d2)

```
.w 1,3,2,0          xi_XpkInfoVersion/LibVersion/MasterVersion/ModesVersion
.l name->"BLZW", long->"Bryan's turbo-charged LZW",
.l desc->"Fast compression and decompression, ratio much like
         'compress' or 'zoo'"
.l 'BLZW'           xi_ID
.l 0x8009           xi_Flags
.l 0x7fffffff       xi_MaxPkInChunk
.l 0                xi_MinPkInChunk
.l 0x00020000       xi_DefPkInChunk (128K)
.l "Compressing","Decompressing","Compressed","Decompressed"
.w 0x64,0           xi_DefMode=100, pad
.l -> mode0         xi_ModeDesc
.l 0 x6             reserved
```

## Mode chain (7 descriptors, 42 bytes each)

xm_Upto partitions the mode value; xm_PackMemory = hash entries*6;
xm_UnpackMemory = 4<<bits (decoder table only; the header's maxlen
word is added at runtime).

| name | upto | bits | packmem | unpackmem | pspd | uspd | ratio |
|------|------|------|---------|-----------|------|------|-------|
| 9 bits  | 14  | 9  | 0xf06 (641*6)   | 0x800   | 100 | 182 | 0xf3 |
| 10 bits | 28  | 10 | 0x1e12 (1283*6) | 0x1000  | 89  | 199 | 0x125 |
| 11 bits | 42  | 11 | 0x3c72 (2579*6) | 0x2000  | 86  | 210 | 0x13d |
| 12 bits | 57  | 12 | 0x78a2 (5147*6) | 0x4000  | 85  | 218 | 0x144 |
| 13 bits | 71  | 13 | 0xf012 (10243*6)| 0x8000  | 87  | 225 | 0x149 |
| 14 bits | 85  | 14 | 0x1e012(20483*6)| 0x10000 | 89  | 231 | 0x14b |
| 15 bits | 100 | 15 | 0x3c006(40961*6)| 0x20000 | 95  | 237 | 0x151 |

Mode → bits is actually computed in code as
`bits = min(mode*7/100 + 9, 15)`; the table above is only what the
descriptors advertise.

## Packer work buffer

`tabsz[bits-9] * 6` bytes of hash entries:
`{char@-? word@0 = -1 sentinel, prefix@2, code@4}` — 6-byte records,
hash index unmasked (see packer.md).

## Decoder work buffer

`(4<<width) + maxlen` bytes:

```
buf+0            buf+maxlen            buf+maxlen+4<<width
[ string stack ] [ 4-byte entries table (grows up)         ]
  grows down
```

Entry: `{f@0, prevcode*2@2}` — f<0 marks literals (-(256-c)) or the
three specials; prev2 stored as code*2 so the follow computes
base+prev2*2 = base+code*4.
