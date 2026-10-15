---
file: layout
---
# mathieeedoubbas 34.46 layout

File 4688B. Hunk table: 3 hunks [0x45f, 0, 0].
- h0 CODE @0x20, declared 0x45f longs (4476B @0x28) but
  the body physically runs 4B further to 0x11a8
  (`f0b0ffff` tail word + pad) — preserved verbatim.
- RELOC32 groups (3,2,1,1,1,1,2,1,1,1 slots, all ->h0),
  HUNK_END.
- h1 CODE 0-len, h2 DATA 0-len — empty linker artifacts.

Resident @h0+8: flags 0x01, ver 34 rev 46, type 9;
name "mathieeedoubbas.library", id "mathieeedoubbas 34.46
(28 May 1988)", init->h0+0x72 (COLDSTART code).

initfn (h0+0x72): lea h0+0x1e4 (default functab); if
AttnFlags bit4 clear -> OpenResource("MathIEEE.resource")
-> found: functab=h0+0x1158, absent: h0+0x1c0; then
MakeLibrary(functab, InitStruct@h0+0x122, dsize=60) and
wires hooks @lib+0x34/0x38 (attn-gated), resource@+0x30,
execbase@+0x28.
