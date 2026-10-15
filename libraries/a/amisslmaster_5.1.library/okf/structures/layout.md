# Layout

- h0 CODE 0x546 longs @file 0x24: bra+strings head, resident @+0x94,
  InitTable @+0x84, functab @+0x58 (10 entries + ffffffff).
- h1 DATA 8 longs (32B): code-looking stub bytes `600a2f0b61ff...`
  (bra/lea/jsr) — DATA-tagged executable block (sublib trampoline?).
- RELOC32: h0 group1 31->h0, group2 7->h1; h1 none.
