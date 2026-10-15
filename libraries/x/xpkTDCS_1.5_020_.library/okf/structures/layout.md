# xpkTDCS — structures

## XpkSubParams (a0 arg block, as decoded from the binary)

| off | field | notes |
|----:|-------|-------|
| 0x00 | xsp_InBuf | input |
| 0x04 | xsp_InLen | |
| 0x08 | xsp_OutBuf | output |
| 0x0c | xsp_OutBufLen | unused |
| 0x10 | xsp_OutLen | written by PackChunk only |
| 0x1c | xsp_Mode | /34 = lazy budget |
| 0x34 | xsp_Sub[0] | workmem ptr (+4 past size word) |

## Library base (dataSize 0x26)

Standard `struct Library` + `xsb_SegList` at +0x22.

## XpkInfo descriptor (64 bytes + 6 reserved longs)

version 1 / libver 1 / masterver 2 / modesver 0;
Name "Sarnath's Doom"; LongName "LZSS family 020+ V1.5";
Desc "LZSS with big window (64 KB), slow packing and fast
decrunching"; ID 'TDCS'; Flags 0x8009;
MaxPkInChunk 0x7fffffff / DefPkInChunk 0x50000;
msgs Annihilate/Reanimate/Oh god, It is done!/Hehe, fast hew.;
DefMode 50; ModeDesc → mode0.

## XpkMode (32-byte header + name)

| mode | upto | flags | packmem | unpackmem | packspd | unpackspd | ratio |
|------|-----:|------:|--------:|----------:|--------:|----------:|------:|
| cremation | 33 | 1 | 0x80004 | 0 | 18 | 560 | 397 |
| ashes | 67 | 1 | 0x80004 | 0 | 8 | 560 | 411 |
| oblivion | 100 | 1 | 0x80004 | 0 | 6 | 560 | 415 |

## Stream format

`[flaglong][items...]` repeating: each nonzero flag long carries
16 2-bit tags MSB-first; a zero flag long is 16 literal longs.
Stream ends with flag-11 tag + 0x0000 token word.
