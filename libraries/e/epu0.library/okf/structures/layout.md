---
file: layout
---
# epu0 layout

File 4192B. 7 hunks:
- h0 CODE 0x1bcB @0x38 — stub + packed resident + InitTable + initfn
- h1 CODE 0xb9cB @0x274 — main routines, RELOC32
- h2 DATA 0xcB @0xe74 — small data
- h3 BSS 8 longs (declared, no body)
- h4 CODE 0xa8B @0xe98 — RELOC32
- h5 DATA 0x64B @0xf7c — string table, RELOC32
- h6 CODE 0x34B @0x1014 — tail stubs, RELOC32

Resident @h0+4: flags 0x80 AUTOINIT; name->h0+0x1e
'epu0.library', id->h0+0x2b, init->h0+0x56.
InitTable @h0+0x56: dsize 0x30, ftab->h0+0x66,
dtab->h0+0x82, initfn->h0+0xae.
