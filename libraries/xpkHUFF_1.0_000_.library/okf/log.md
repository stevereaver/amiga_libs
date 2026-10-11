# xpkHUFF 1.0 — RE log

## Session

1. IRA disassembly of `binary/xpkHUFF_1.0(000).library` (1796B).
2. Functab decoded — word-offset form, 10 vectors; `-48`/`-24`
   wrap via `0xFF6E` to the shared `moveq #0,d0` stub at hunk+0.
3. Identified as Zimmerman's Huffman XPK sublib — sorted-list
   Huffman (22B nodes, before-equals insert, marker walk =>
   1 bit/level, `roxr` MSB-first accumulation) with a password
   layer: `pwhash` + chained XOR/ADD descramble.
4. Descriptor mapped to standard `XpkInfo` — flags `0x2009`
   (0x2000 = password support), mode "dynamic",
   packmem 0x3208 / unpackmem 0x1004.
5. Reconstructed `xpkHUFF.c` + `xpkHUFF_lib.s` + build files.
6. Host verification:
   - sed-stripped `host_core.c` + harness (static arena,
     `-no-pie` for 32-bit Amiga pointers on 64-bit host).
   - Bug found: `pwhash` phase-2 `rol.w` leaked 32-bit shift
     into the high word — fixed by masking to 16 bits.
     Verified `"secret" -> 0x4D840818` by hand-trace + model.
   - Independent Python decoder validates C stream end-to-end.
   - Independent Python encoder byte-identical to C output on
     all inputs incl. Fibonacci frequencies (deep >16-bit
     codes, split emit).
   - 100KB single-symbol input reproduces the faithful `dbf`
     wrap: decodes `(u16)99999+1 = 34464` symbols.
   - Bad flag -> -26, missing/wrong password -> -32,
     incompressible input -> -17, all confirmed.
7. Binary comparison: hunk header/datatab/resident byte-
   identical modulo relocated pointers; functab structure and
   all 10 vector targets identical; descriptor identical modulo
   pointers.  Code hunk larger (GCC codegen, expected).

## Known gaps

- Generated code hunk (3360B) exceeds original (1676B) — GCC
  `-O2` without the original's hand-packed register flow;
  semantics verified instead of byte-identity.
- `inlen==0` pack path dereferences a null list on the original
  too (faithful crash, not a reconstruction bug).
