---
file: vectors
---
# Vectors

Absolute-long functab @h0+0x15e, 6 slots (+0 term then
`ffffffff`):

| LVO | target | role |
|-----|--------|------|
| -6  | h0+0x244 | Open |
| -12 | h0+0x252 | Close |
| -18 | h0+0x17a | Expunge — RemLibrary, frees 0x7e |
| -24 | h0+0x242 | Reserved — returns 0 |
| -30 | h1+0x12  | AvailFonts/NewFontContents-style enumerator (returns -1 under stubs) |
| -36 | h1+0     | OpenDiskFont-family entry (returns 2 — reads font dir) |

initfn@h0+0x80 (called by exec post-MakeLibrary) + init bootstrap
@h0+0x50 stores seglist@abs, MakeLibrary(dsize 0x38), AddLibrary.
