---
file: layout
---
# samp 1.0 layout

File 3924B. Single CODE hunk 0x3a3 longs (3724B @0x20).
Tail: 1 RELOC32 group, 37 slots ->h0, END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #0,d0 / rts` stub |
| 0x04 | Resident: flags 0x00 (plain resident — exec calls rt_Init), ver 1, type 9; name->0xdad id->0xe69 init->0xca |
| 0x24-0x8f | 18 `jmp <abs>` vector slots (relocated) |
| 0x90 | library node base — AddLibrary'd here (LN_TYPE 9 follows) |
| 0xca | init: stash a0/a6 at pc-rel scratch (+0xb2/+0xb6), OpenLibrary(dos), `clrb` flag, AddLibrary(pc-rel 0x8c-adjacent base) |
| 0xec/0xfa/0x110 | open (`addqw a6@32`)/close(`subqw`)/expunge (RemLibrary+CloseLibrary) |
| 0xdad/0xe69 | name/idstr |
