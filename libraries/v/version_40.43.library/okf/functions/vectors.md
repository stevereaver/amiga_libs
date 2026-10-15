# version40.43 — vector map

RomTag @ h0+4, AUTOINIT, EndSkip->0xbe (past the stub).
InitTable @0x48: dsize=0x2a, ftab->0x58 (word-offset mode),
dtab=0, initfn->0x64.

| LVO  | target | role |
|------|--------|------|
| -6   | 0x78   | Open: `addqw #1,a6@(32); movel a6,d0; rts` |
| -12  | 0x80   | Close: `subqw #1,a6@(32)`; on 0 -> inline Remove + FreeMem(lib), return seglist |
| -18  | 0xba   | Expunge stub: `moveq #0,d0; rts` (never expunges) |
| -24  | 0xba   | reserved: same stub |

initfn @0x64: `exg d0,a5; a5@(34)=execbase; a5@(38)=seglist;
a5@(22)=42 (revision); exg; rts`.
No datatab — InitStruct skipped; lib fields beyond Library
header come only from initfn.
