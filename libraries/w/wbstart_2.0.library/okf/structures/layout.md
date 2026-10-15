---
file: layout
---
# wbstart 2.0 layout

File 4056B. 2 hunks:
- h0 CODE 0x3cd longs (3892B @0x24): 'wbstart.library'+id strings
  head, packed RomTag @+0x56 (flags 0 = COLDSTART, ver 2, type 9),
  functab @+0x70, initfn @+0xde, handler + support code.
- h1 DATA: hunk table declares 9 longs (36B) but file body holds
  only 1 long (4B zero) — linker alloc/body mismatch (same quirk
  as 2.2, which declared 10 longs).

Relocs: 15 ->h0 (resident fields, code refs) + 6 ->h1
(SAS/C a4-frame data refs; globals via a4 = DATA base).

Init path: rt_Init -> h0+0xde requires exec v39+, calls
MakeLibrary(functab@h0+0x70, dsize, initfn), sets up NewList +
semaphore, AddLibrary.
