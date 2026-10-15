---
file: layout
---
# ptable.library 1.0 layout

Binary: 3712 bytes, hunk0 CODE = 0x391 longs = 3652 bytes @file+0x20.
Tail: one DREL16 group (7 word-offset slots: 0x6,0xa,0x12,0x16,0x1a,
0x60,0x68), HUNK_END.

## hunk0 offsets

| off | contents |
|-----|----------|
| 0x00 | module stub `moveq #0,d0 / rts` |
| 0x04 | Resident: matchtag->+4, endskip->0xe44, flags 0x80 AUTOINIT, ver 1, type 9, pri 0x16 |
| 0x1e | name `\ptable.library` |
| 0x2c | idstr `$VER: ptable.library 1.0 (16.05.2026) [68000]` |
| 0x5c | InitTable: dsz=0x2a, functab->+0x6c, datatab=0, initfn->+0x7a |
| 0x6c | word-offset functab: ffff, entries 0x24,0x32,0x46,0x84,0x17e, ffff (5 vectors) |
| 0x7a | initfn + code; strings [RDB]* embedded 0x126-0x1d4 |
| 0x2a0 | `RDB0` marker bytes inside a probe routine |
| 0x4d0/0x536/0x56e/0x8ce | RDSK / FSHD / PART / LSEG magic compares |
