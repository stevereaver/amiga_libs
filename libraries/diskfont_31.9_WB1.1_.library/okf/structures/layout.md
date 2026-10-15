---
file: layout
---
# diskfont 31.9 layout

File 3936B. 13 hunks (tablesize 0xd):

| h | tag | size | role |
|---|-----|------|------|
| 0 | CODE | 0x248 | resident@+4, init@+0x50, functab@+0x15e, name/idstr |
| 1 | CODE | 0x20 | support code (2 relocs) |
| 2 | DATA | 0x10 | |
| 3 | CODE | 0x27c | font-dir/scan code (18 relocs) |
| 4 | DATA | 0x10 | |
| 5 | CODE | 0x368 | main font ops (29 relocs) |
| 6 | DATA | 0x88 | |
| 7 | CODE | 0xec | |
| 8 | DATA | 0 | empty hunk (linker artifact) |
| 9 | CODE | 0 | empty hunk |
| 10 | CODE | 0xf0 | (10 relocs) |
| 11 | CODE | 0x68 | (5 relocs) |
| 12 | CODE | 0x3c | (3 relocs) |

All tails RELOC32; ~65 relocs ->h0 + cross-hunk.

Resident @h0+4: flags 0x00, ver 31, type 9; name->+0x1e
('diskfont.library'), id->+0x30 ('diskfont 31.9 (23 Nov 1985)'),
init->+0x50 (code — not an InitTable; WB1.x predates AUTOINIT).
