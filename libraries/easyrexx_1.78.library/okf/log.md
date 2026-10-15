# easyrexx_1.78.library — work log

## 2026-10-15 — full reverse engineering + reconstruction

- Parsed hunk layout: CODE 2772B + DATA 24B, RELOC32 relocs
  (h0->h0 23, h0->h1 7, h1->h0 2), AUTOINIT RomTag @0x4,
  InitTable in DATA hunk at +4, 17-vector absolute functab @0x9d4.
- Identified library: EasyRexx 1.78 — ARexx host-port / RexxMsg
  manager (port lifecycle, CreateRexxMsg/CreateArgstring send path,
  inbound cmd dispatch via name->key table + string argument list).
- Generated `source/easyrexx_h0.s` via `work/genasm.py`
  (capstone-driven verbatim emission, data islands, mid-insn branch
  labels, relocated operands as symbols); hand-wrote
  `source/easyrexx_h1.s` (24B InitTable block).
- `source/Makefile` + `fixup.py` (RELOC32 record reorder to original
  producer order) -> **byte-identical**, md5
  `4c5c75ff4c16e7b4e7e7b070853719b7`.
- `work/oracle.py` (machine68k, M68020): exec port registry with real
  msg queues, utility taglist walker + stricmp, dos stubs,
  rexxsyslib base planted at DATA+0x18 (the thunk's out-of-bounds
  read site).  All 17 vectors exercised incl. create/send/dispatch/
  cleanup flows and failure paths -> **RUNTIME-IDENTICAL** to the
  original binary.
- See findings/quirks.md for the latent defects (out-of-bounds
  rexxsyslib base global, uninitialised a4 ABI, _v84 partial-failure
  leak, dead rebase loop).
