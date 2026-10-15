---
file: defects
---
# Findings

- **Vector -42 jump-table smash (real defect):** `link a5,#-26`
  is immediately discarded by `moveal a6,a5` (a5:=libbase), so
  the 26-byte commodity-object init block is built at lib-26 —
  on top of the library's own negative-size jump stubs for
  -6/-12/-18/-24. `unlk a5` then takes sp:=libbase and pops the
  saved regs + return address from the lib struct. Every call
  to -42 corrupts Open/Close/Expunge/Reserved vectors (observed
  under oracle: post--42 close/expunge run wild, 39.8M invalid
  accesses, deterministic in both binaries).
- **Open dead store:** `lsr` BPTR of h0+0x130c written to
  lib+0x22, then ExecBase stored to the same slot; seglist is
  actually kept in the hunk slot at h0+0x13c (initfn writes it,
  expunge reads it back).
- initfn stores the seglist via absolute-long operand into the
  CODE hunk itself (code+data cohabitation); 5 reloc slots do
  double duty covering the embedded Resident+InitTable.
- Hardcoded CIA-B register block access at 0xbfd000 in -78/-84/
  -90 (parallel port bit dance alongside misc.resource claims).
- -24 returns 0 stub; -84/-114 return -1 on magic check.
- All entries verified identical orig vs rebuild: BYTE-IDENTICAL
  build, RUNTIME-IDENTICAL oracle trace.
