# xpkACCA 1.2 (000) — OKF index

XPK sublibrary: "Andre's Code Compression" by André Osterhues
("$VER: xpkACCA V1.2 (1 Oct 2013)", id 'ACCA', xi_Flags 0x8009,
DefMode 100). Long name "Andre's Code Compression V1.2",
description "Similar to RDCN, but more efficient" — ACCA is indeed a
refined RDC (Ed Ross' LZ/RLE scheme): same 16-symbol flag groups and
token classes as xpkRDCN, extended with a hash-chain packer.

Two packers selected by `xsp_Mode`:

- **turbo** (mode <= 79): one-candidate matcher over a 4096-entry
  head table at workbuf+0, hash `h = (b0b1 ^ rol4(b0b2)) & 0xfff`;
  workmem 0x4004 bytes (4-byte size header + 0x4000 table).
- **crawling** (mode > 79): hash-chain matcher, heads = 65536 longs
  at workbuf+0 keyed by `h = (b0<<8)|((b1+b2)&0xff)` (byte-add carry
  never propagates), chain ring = 8192 longs at workbuf+0x40000
  keyed by `pos & 0x1fff`; workmem 0x48004 bytes.

Both emit the same stream: `[u16 flags MSB-first][16 symbols' bytes]`;
flag 0 = literal, 1 = token byte `class<<4|lo4`:

| class | extra | decode |
|-------|-------|--------|
| 0     | B     | run of B, len lo+3        (3..18)   |
| 1     | b1,b2 | run of b2, len lo+16*b1+19(19..4114)|
| 2     | —     | emit table16[lo] twice             |
| 3..13 | b2    | match len=class, dist=16*b2+lo+3  |
| 14    | —     | zero run, len lo+3         (3..18)   |
| 15    | b2,b3 | match len=b3+14, dist=(b2<<4|lo)+3 |

table16 @0x53a: `00 01 02 03 04 08 10 20 40 55 60 80 aa c0 e0 ff`.

## Contents

- `functions/vectors.md` — LVO map + routine map, verified.
- `structures/layout.md` — hunk/init tables, descriptor, workmem.
- `findings/defects.md` — quirks/bugs preserved in the reconstruction.
- `log.md` — session log.

## Files

- `binary/` — original (ignored).
- `source/xpkACCA.c` — C reconstruction (both packers, decoder, lifecycle).
- `source/xpkACCA_lib.s` — RomTag/InitTable/datatab/descriptor/modes.
- `source/genfunctab.py`, `functab_stub.s`, `Makefile` — two-pass
  word-offset functab build.
- `work/` — objdump dump + host harness (ignored).
