# xpkHFMN_1.4_020_.library — RE log

- IRA disasm (existing `work/xpkHFMN_1.4(020).asm`) read end-to-end;
  functab re-parsed from raw bytes (word-offset format, -24 uses a
  negative offset onto the entry stub).
- Pack: heap Huffman builder decoded (sift = LAB_002F, merge =
  LAB_001F, code collect = LAB_0022, emit = LAB_0026-002E).
- Unpack: trie build (LAB_0036-003D, leaf = 0xffffffSS negative long),
  10-bit fast table (LAB_003E-0042), decode loop (LAB_0044-0047).
- Emit quirk: tree pad uses ADDX with X always =1 -> a '1' pad bit.
- Host verification (work/host, model.py, dec.py):
  - round-trips: aaaa 5000->636, mixed 8000->1890, readme 14330->9682,
    elfish 30000->17176, hello 8400->3081, skewed 20000->6669,
    two 200->36, skew7 2350->437 — all byte-exact vs Python model;
  - rnd4k/rnd60k/allbytes/1-byte: -17 (output > input) as shipped.
- m68k build: all 10 vectors resolve; RomTag/datatab byte-identical;
  descriptor + mode block identical modulo relocated pointers.
