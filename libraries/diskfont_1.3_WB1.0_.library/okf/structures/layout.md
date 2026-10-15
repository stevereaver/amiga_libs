---
file: layout
---
# diskfont 1.3 layout

13 hunks: h0 CODE (stub+resident+initfn) then per-function
CODE/DATA hunks (h1..h12; h8 DATA and h9 CODE are empty
linker artifacts). RELOC32 tails per hunk.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #-1,d0 / rts` stub |
| 0x04 | Resident: flags 0x00, ver 1, rev 3; init->h0+0x4c |
| 0x4c | rt_Init: MakeLibrary(ftab->h0+0x158, dtab->h0+0x130,
       | initfn->h0+0x7a, dsize 0x38, seg) then AddLibrary |
| 0x7a | initfn: OpenLibrary dos + graphics |
| 0x130 | InitStruct datatab |
| 0x158 | functab: 6 absolute longs + ffffffff |
