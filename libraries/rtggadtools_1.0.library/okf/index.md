# rtggadtools_1.0.library

RTG (retargetable-graphics) gadget-class support library. `rtggadtools.library` v1.0.

- Format: Amiga HUNK load file, 5 hunks (4x CODE 0x3e9 + 1x DATA 0x3ea) plus interleaved HUNK_DEBUG (0x3f1) LINE records and a HUNK_SYMBOL (0x3f0) tail.
- AUTOINIT (resident flags 0x80). Resident @h0+4; rt_Init relocates to InitTable @h1+0.
- InitTable: dsize 0x7c, functab -> h4+0, datatab 0, initfn -> h0+0x20.
- Functab: 13 absolute-longword vectors + 0xffffffff terminator; names/id strings follow in h4 tail.
