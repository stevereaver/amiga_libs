# version39.29WB3.0 — layout

h0 body 0xc0 B: DOS stub 0x00, RomTag 0x04-0x1d, name 0x1e,
idstr 0x2e, pad, InitTable 0x48, word functab 0x58
(ffff marker, offs 0x20/0x28/0x62/0x62 rel. to ftab),
initfn 0x64, Open 0x78, Close+inline-expunge 0x80, stub 0xba,
EndSkip 0xbe, pad to 0xc0.

Library dsize 0x2a: only std fields used — +16/18 sizes,
+20 ver (RomTag), +22 rev (initfn), +32 opencnt, +34 execbase,
+38 seglist.
