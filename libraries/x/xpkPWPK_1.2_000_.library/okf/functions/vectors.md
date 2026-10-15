---
type: Function
title: xpkPWPK 1.2(000) vector map
tags: [lvo, functab, xpk]
---

# xpkPWPK vectors (word-offset functab @code+0x94, leading+trailing 0xffff)

| LVO | word | target | role |
|-----|------|--------|------|
| -6  | 0x0020 | 0x0b4 | Open (cnt++, clear LIBF_DELEXP) |
| -12 | 0x002e | 0x0c2 | Close (cnt--, expunge if flagged) |
| -18 | 0x0040 | 0x0d4 | Expunge (deferred via flags bit3) |
| -24 | 0xff6c | 0x000 | reserved stub -> moveq#0/rts |
| -30 | 0x007e | 0x112 | XpksPackerInfo -> lea pc@XpkInfo |
| -36 | 0x012c | 0x1c0 | XpksPackChunk (A0=xsp) |
| -42 | 0x0086 | 0x11a | free packer ctx: `FreeMem(--(xsp+0x34))` |
| -48 | 0xff6c | 0x000 | reserved stub |
| -54 | 0x05a4 | 0x638 | XpksUnpackChunk (A0=xsp) |
| -60 | 0xff6c | 0x000 | reserved stub |

## Internal layout

- 0x132 ctx alloc/entry (allocs `0x30046 + (1<<e3)*8` bytes,
  flags=0): handle = base+4 (size cell at -4); fields: +0..15
  mode words {9,e1,e2,e3,0x200,1<<e1,1<<e2,1<<e3}, +16:1,
  +20:0x00020003, +54:tab2, +58:tab1, +62:2<<e3; hash area at
  handle+66 .. +0x30045, chain tables at +0x30046.
- 0x21e encoder (PowerPacker LZ): clears tables, greedy hash match,
  bitwriter `MOVE.L D5,(A6)+` flush on carry, 32k window
  (`lea 32767(a0)`).
- 0x638 unpack entry; 0x666 bit-reader decoder with bit-reversal
  tables at code+0x5b4/0x634 and match-len class table
  code+0x59c (4 bytes per mode: pad + 3 shift exponents).
- 0xa72 helpers: LAB_0068 rolling sum (ror/add over cstr),
  LAB_006A rotated-add checksum, LAB_006C XOR-crypt a buffer.
- 0xa9a XpkInfo + 0xaf2.. mode descriptors.
