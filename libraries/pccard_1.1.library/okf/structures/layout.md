---
file: layout
---
# pccard 1.1 layout

File 5420B. Header 0x3f3, no names, tablesize 1.
h0 CODE @0x18: body @0x20 (0x50d longs = 5172B), tail
RELOC32 @0x1454: one group n=49 ->h0 (offs 0x4c..0x4c0),
term, END @0x1528, EOF 0x152c.

hunk+0x00: rts stub (moveq -1). Strings: +0x0a
"pccard.library", +0x19 "pccard.library 1.1
(23.11.2002)\n", +0x3a "utility.library".
RomTag @+0x4a: MatchTag->self, EndSkip->+0x9e,
RTF_AUTOINIT|ver1|NT_LIBRARY|pri0, name->+0x0a,
id->+0x19, init->+0x9e.
Functab @+0x64 (6 abs longs + ffffffff).
InitData @+0x80: byte-offset cmds -> ln_Type=9,
ln_Name=+0x0a (reloc'd src), lib_Flags=6, ver/rev=1,
idstr=+0x19 (reloc'd src); ends +0x9c.
InitTable @+0x9e: dsize 0x2e, ftab +0x64, dtab +0x80,
initfn +0xae.

lib fields: +0x22 segList, +0x26 execBase, +0x2a
utilityBase (dsize 0x2e ends +0x2e).

Data region +0x1b0..+0x4c4: tuple->TagItem tables
({TAG_USER|n, data} 8B records incl. sub-lists @+0x524,
arrays @+0x554/0x570/0x588) and ptr array @+0x3a8 (71
entries, reloc'd) indexed by tuple code. Jumptab
@+0x624 (33 u16). Speed-scale table @+0x59d (15B),
pow10 table @+0x5ae (8 u32). Code +0x5ce..+0x1434.
