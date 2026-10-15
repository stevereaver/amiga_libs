# xpkFAST 1.2 — RE log

## Decode

- IRA disassembly (`work/fast.asm`, gitignored) of
  `binary/xpkFAST_1.2(000).library`.
- AUTOINIT resident, word-offset functab, 10 vectors; `-24` and
  `-60` wrap to the entry stub.
- Codec: LZ77, 4 KB window, len 3..18 tokens `(off<<4)|(18-len)`,
  literals forward + ctrl/token words backward from
  `out+(InLen&~3)-2`; two packers selected by unsigned
  `xsp_Mode < 79`.
- Crawler hash decoded via the `moveq #-1` seed: high word stays
  0xffff through `lsl.w #8`, `add.l d1,d1`×2 gives index
  `0xfffc0000|h16<<2` which cancels the `+0x40000` table base —
  hash table at alloc+4, chain table at alloc+0x40000.

## Reconstruction

- `xpkFAST.c` — lifecycle, PackerInfo, PackFree, PackReset,
  speedy+crawling packers, shared `pk_tail` compactor, unpacker.
- `xpkFAST_lib.s` — RomTag/initstruct/datatab/descriptor/lib.s
  init; `genfunctab.py` two-pass functab; `endmodule.s` emits
  the trailing `00 21 e2 34`.

## Bugs found & fixed during reconstruction

- Host harness pointer truncation (64-bit host, 32-bit Amiga
  pointer fields) → static low arena.
- Tail copier misread: bit-2 step copies ONE longword (not two);
  `copied = size & ~1`.
- Mixed-width hash arithmetic: `add.b`/`move.b` act on the low
  byte of the *shifted* value only — explicit `(h&0xff00)|...`
  masking.
- **Decoder sentinel**: original keeps the sentinel in d1 via
  `addx` (X=1 into bit0 on reload); exhaustion is
  carry-out-with-d1==0, which a `!bits`-on-raw-word check cannot
  express — caused phantom match/item drift on words with zero
  low bits.  Rewrote the loop to consume bit15 on reload and
  treat a shift that empties the register as the sentinel pop.
- Crawler len cap: original's 17-compare chain yields len ≤ 17;
  fixed `while (len < 18)` → `len < 17`.

## Verification

- Host round-trips: all pass, both modes (incompressible → -17).
- Independent Python decoder (modeled on disasm): validates all
  C-produced streams end-to-end.
- Independent Python encoder (speedy + crawler, modeled on
  disasm): **byte-identical streams** on all test inputs
  (text, repeats, mixed alphabet, 3..18-length sweeps,
  alternating, zeros, 56 KB mixed).
- Binary vs original: RomTag/datatab byte-identical (modulo
  functab/func relocations); functab marker+entries decode to
  the same vector map; descriptor + mode blocks + strings
  byte-identical modulo relocated pointers; tail `00 21 e2 34`
  present.
- Code layout differs (GCC codegen; code hunk 0x724 vs 0x6b8) —
  expected, all vectors resolve via the generated functab.
