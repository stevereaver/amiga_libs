# Work log — xpkLZBS 2.1 (000)

- IRA/objdump disassembly of the 2036-byte binary; AUTOINIT header,
  functab @0xb4 (`ffff` marker + 10 offsets + `ffff`), datatab
  version 2 revision 1.
- Resolved all vectors; -24/-60 wrap to the entry stub.
- Decoded packer (0x1a6): mode->bits threshold chain, workmem =
  `(1<<bits)*4 + 0x40004` (hash head 65536x4 + chain ring),
  3-byte hash `(b0<<8)|((b1+b2)&0xff)` via `moveq #-1` negative-index
  trick, `d5 = dist<<16|len` register packing, `bf`-free bit writer
  emitting token LSB-first.
- Decoded decoder (0x402): LSB-first getbits (`add.b/roxr`), literal /
  match / run-escape tokens, dist-width table @0x3e8 (13 powers of 2).
- Bit-order subtlety resolved empirically: emitted LSB-first +
  ROXR accumulation => fields pass through verbatim.
- Reconstructed in C (`source/xpkLZBS.c`), Amiga lib glue in
  `xpkLZBS_lib.s`; two-pass `genfunctab.py` reproduces the original
  `ffff`-marked word-offset table.
- Built with m68k-amigaos-gcc -m68000; RomTag/idstr/datatab bytes and
  descriptor/mode records verified against the original
  (mode table byte-identical, descriptor field-identical modulo
  relocated pointers).
- Host harness (work/host.c, -m32): 74 round-trips byte-exact across
  all 12 modes, distance boundaries 1..8190, literal-run boundaries
  19..4095, and a 60-file randomized sweep; rejects (-17) only for
  incompressible/tiny inputs — faithful bit-budget behaviour.
- Independent Python decoder (work/dec.py) written from the recovered
  spec decodes all 40 packable streams byte-exact — format verified.
- Defects recorded in findings/defects.md.
