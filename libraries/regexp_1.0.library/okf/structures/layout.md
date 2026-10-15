---
file: layout
---
# regexp 1.0 layout

File 3952B. 8 hunks:

| h | tag | size | role |
|---|-----|------|------|
| 0 | CODE | 0x20 | stub + packed Resident@+4 + relocs ->h0/h2/h7 |
| 1 | CODE | 0x148 | initfn@+0 (`link a5`) + support |
| 2 | DATA | 0x10 | InitTable {dsz=0x192, ftab->h3+0, dtab=0, initfn->h1+0} — fields stored as 0, relocated |
| 3 | CODE | 0x618 | main regexp engine |
| 4 | CODE | 0x68 | helper |
| 5 | CODE | 0x424 | helper |
| 6 | DATA | 0x174 | data |
| 7 | CODE | 0x3c | functab@end + 'regexp.library'@+0x20 + 'Version 1.0'@+0x30 |

Resident @h0+4 is PACKED (no pad after MatchWord): mt@+0,
matchtag@+2, endskip@+6(=0x1e), flags@+0xa=0x80, ver@+0xb=1,
name@+0x12->h7+0x20, id@+0x16->h7+0x30, init@+0x1a->h2+0.
