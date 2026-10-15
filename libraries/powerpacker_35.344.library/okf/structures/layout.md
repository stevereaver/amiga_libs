---
file: layout
---
# powerpacker 35.344 layout

File 6036B. h0 CODE 0x5a3 longs (5772B @0x24), RELOC32
42 slots ->h0 + 5 slots ->h1. h1 BSS 0x3eb 4 longs (16B
globals; header table reserves 4, hunk's own size field
in file is 0). Resident @h0+0x32, standard 22B: flags
0x80 AUTOINIT, ver 35, name->h0+4 "powerpacker.library",
id->h0+0x18 "pplib 35.344 (24.5.92)", init->h0+0x78.

InitTable @h0+0x78: dsize 0x28, ftab->h0+0x1ba (22 abs
longs, -1 term), dtab->h0+0x4c, initfn->h0+0xb8. Dep
strings dos/intuition/graphics.library inline @0x88-0xb6
before initfn. datatab fills lib header (rev 0x158=344
@+0x16).

Other strings: PP20/PP2 magic refs, 'PPMM' @0xa52/0xcc7
(FreeMem hook tag), reqtools nag "You need
reqtools.library" @0x96b, file/error msgs @0x9bb-0xa4a
("unable to open file", "encrypted file", "incorrect
password", "unknown PP data header", "empty file",
"unknown error occured"), requester text "Incorrect!"/
"Please verify"/"Error! Restart" @0xd90-0xdbb.
