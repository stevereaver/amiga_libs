# xpkHFMN_1.4_000_.library — RE log

- IRA disasm `work/hfmn14000.asm`; header/functab/datatab re-parsed
  from raw bytes.  Same AUTOINIT skeleton as the completed
  `xpkHFMN_1.4_020_` (RomTag@4, inittab@0x62, datatab@0x72,
  functab@0x92 word-offset format).
- Identified as the 68000 build of xpkHFMN V1.4: same idstr, same
  descriptor scalars, same workmem sizes (0x1a0e/0x1004); LibInit has
  no AttnFlags gate; longname is "Huffman V1.4"; mode speeds
  0x81/0xc0.
- Spot-checked PackChunk head (AllocMem 0x1a0e, store, histogram) and
  UnpackChunk head (AllocMem 0x1004, lea +0x800 fast table, -1 leaf
  marks) — same algorithm as the verified 020 codec, 68000 codegen.
- Reconstruction: copied the 020 sources verbatim; lib.s edits = drop
  the CPU gate from LibInit, longname, mode speeds; Makefile `-m68000`.
- m68k build: all 10 vectors resolve via the generated word-offset
  functab; RomTag/header/datatab bytes identical; LibInit bytes
  `2240 2348 0022 4e75` match the original exactly; descriptor and
  mode block byte-exact modulo relocated pointers.
- Host verification (work/host, dec.py from the 020 work dir):
  - round-trips: hello 8400->3081, aaaa 5000->636, mixed 8000->1890,
    skewed 20000->6669, readme 14330->9682, elfish 30000->17176,
    skew7 2350->437, two 200->36 — all ok;
  - allbytes/rnd4k/rnd60k/rnd64k: -17 (output > input) as shipped;
  - pack streams byte-identical to the verified 020 build on all 10
    inputs; independent Python decoder reproduces input.
