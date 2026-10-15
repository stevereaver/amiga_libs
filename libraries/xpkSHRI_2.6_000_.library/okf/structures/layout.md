---
file: layout
---
# xpkSHRI 2.6(000) layout

File 4316B. Single hunk0 CODE 0x413 longs (4172B @0x20).
Tail: RELOC32 — 23 ->h0 entries (incl. mode-table pointers
0xe64..0xf84), END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #-1,d0 / rts` stub |
| 0x04 | Resident: flags 0x80 AUTOINIT, ver 2; name->+0x1e id->+0x2e init->+0x64 |
| 0x1e | 'xpkSHRI.library' |
| 0x2e | '$VER: xpkSHRI V2.6 (1 Oct 2013) by Matthias Meixner\r\n' |
| 0x64 | InitTable: dsize 0x26, ftab->+0x94, dtab->+0x74, initfn->+0xac |
| 0x94 | word-offset functab: ffff + 10 words + ffff |
| 0xac | initfn (seglist store, flag test) |
| 0xe1c | word table + packer-info/mode tables + strings to 0x104c |
