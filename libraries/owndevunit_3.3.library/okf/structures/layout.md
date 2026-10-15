---
file: layout
---
# owndevunit 3.3 layout

File 4476B. 3 hunks (table sizes 0x4e/0x53/0x390):
- h0 CODE: record declares 0x4e longs but the file carries 0x4f
  — an extra body long (205f4e75) sits between the declared
  body and the RELOC32 tail. Quirk preserved verbatim.
- h1 DATA: table entry 0x53 longs (332B alloc) but record
  declares 0x41 (260B body) — alloc/body mismatch.
- h2 CODE 0x390 longs (3648B) — the main implementation
  (OwnDevUnit/AttemptDevUnit/FreeDevUnit/AvailDevUnit code,
  timer.device strings, rexxsyslib ref).

Resident @h0+4: packed, flags 0x80 AUTOINIT, ver 3, type 9;
name->h0+0x1e, id->h0+0x32, init->h0+0x98.
InitTable @h0+0x98: dsize 0x22, functab->h0+0xa8 (11 abs longs),
datatab->h0+0xd8, initfn->h0+0xf8.
