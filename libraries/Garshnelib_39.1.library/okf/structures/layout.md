---
file: layout
---
# Garshnelib 39.1 layout

File 4716B. 2 hunks: h0 CODE declared 0x435 longs but body
physically runs to 0x10f8 (4B overrun, `4e75 0000` tail),
RELOC32 22 slots ->h0; h1 DATA 0x34 longs @0x1180 (a
forward-pointer table copied into the lib at +0x3c),
RELOC32 2 slots ->h0.

Resident @h0+4: flags 0x80 (AUTOINIT-marked) ver 39 type 9,
name/id -> "Garshnelib.library" / "Garshnelib.library 39.1
(23.10.94)", init -> h0+4 i.e. BACK AT THE RESIDENT —
degenerate (see defects). Real initfn is h0+0x22.

initfn (h0+0x22): takes d0=pre-allocated lib base; writes
type/flags/ver/rev/name/idstr, stores functab ptr
(h0+0xf8c) at lib+0x38, copies the h1 table into lib+0x3c
with relocated pointers. Calls bsr ->h0+0x100c stub
(moveq#0/rts — dead).
