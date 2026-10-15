# xpkTDCS 1.2 — structures

## XpkSubParams (a0 arg block)

| off | field | notes |
|----:|-------|-------|
| 0x00 | xsp_InBuf | input |
| 0x04 | xsp_InLen | `remaining` counter starts here |
| 0x08 | xsp_OutBuf | output; outend = OutBuf+InLen |
| 0x0c | xsp_OutBufLen | unused |
| 0x10 | xsp_OutLen | written by PackChunk on success only |
| 0x14 | xsp_Flags | unused |
| 0x18 | xsp_Number | unused |
| 0x1c | xsp_Mode | unused |
| 0x20 | xsp_Password | unused |
| 0x24 | xsp_LibVersion | unused |

## Library base (dataSize 0x3c)

`struct Library` then: +0x22 unused, +0x26 seglist (BPTR).

## Hash table (AllocPooled 0x80000, zeroed)

`tab[key*2]` = capacity, `tab[key*2+1]` = block ptr,
key = ((b0<<8)|b1)^b2, 65536 entries.
Block: `blk[0]` = used, `blk[1..cap]` = position pointers.
Create: cap=2, blk = AllocPooled(16).  Grow: cap≤63 → double,
else +64; shrink -64 when used>1 && cap/2≥used && cap>64.
Realloc block size = (cap+2)*4.

## XpkInfo descriptor (XpksPackerInfo result)

version 1 / libver 1 / masterver 2 / modesver 0;
Name "TDCS"; LongName "The Doom that Came over Sarnath";
Desc "Lempel-Ziv-77 implementation with big window";
ID 'TDCS'; Flags 0x8009; MaxPkInChunk 0x7fffffff /
DefPkInChunk 0x50000; DefMode 49; ModeDesc → mode0.
Copyright/author text: "Based upon some experiments with
packer, (c)DYNA-Tech".

## XpkMode (32-byte block)

| mode | upto | flags | packmem | unpackmem | packspd | unpackspd | ratio |
|------|-----:|------:|--------:|----------:|--------:|----------:|------:|
| direct match | 49 | 1 | 0x800a0 | 0 | 20 | 1500 | 500 |

## Stack frame (PackChunk, sp@-based, 156-byte frame)

| off | var |
|----:|-----|
| +54 | realloc-block temp |
| +62 | emit-len slot init 0 (sp@98 shares; see below) |
| +74 | pending len (low word written via +76 alias) |
| +78 | lazy count (low word via +80 = d6) |
| +82 | lookahead len (low word via +84 = d5) |
| +94 | emit dist → copied to +108 before emit |
| +98 | emit len |
| +108 | find's dist result |
| +116 | flagslot ptr |
| +120 | flag accumulator |
| +124 | bitcnt (15→-1) |
| +132 | tab base |
| +140 | outend = OutBuf+InLen |
| +144 | InLen snapshot |
| +148 | remaining (low word at +150 is the maxlen clamp) |
