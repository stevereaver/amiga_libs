# xpkNUKE_1.7.library — reconstruction log

- Two-hunk file: CODE + DATA (XpkMode/XpkInfo descriptors live in DATA).
- Absolute-long function table at code+0x2e, -1 terminated; dataSize 0x22
  (plain Library); seglist kept in a code slot (code+0x7a), not in base.
- Entry stub returns -1 (sic).
- Codec identical to 1.9 family: pair-hash chain window 0x6a8f, four
  interleaved output streams (token flags / 2-bit literal-run counts /
  offset-class nibbles / offset residual bits), literals stored backward
  from outbuf end, 0xfb-padded.
- Generational diffs vs 1.9 (documented in source header): wrapper
  marshalling, three separate AllocMem workmems (92B + 0x20000 + 0x10000,
  memset each PackChunk), jump-table dispatch `jmp pc@(tab,d0:w)`,
  window edge test `d6 < d4` (1.9: `<=`), literal-tail copy overflow
  check off-by-one vs 1.9.
- Subagent produced C reconstruction; oracle initially flagged three
  packer mismatches (txt first-byte, ramp @0x8a, rnd8k @0x26b) — later
  fixed; final run: all corpus streams byte-identical, all round-trips
  pass. Only embedded code addresses differ (expected: not byte-identical).
- machine68k oracle: full vector exercise + PackerInfo + PackFree path
  identical modulo code addresses.
