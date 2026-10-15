---
file: layout
---
# xpkLIN4 1.1 layout

File 3732B. Single hunk: CODE 3596B body @file+0x20.
Tail: RELOC32, 21 slots ->h0 (0x6..0xd56), HUNK_END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | stub `moveq #0,d0 / rts` (target of the reserved vectors) |
| 0x04 | Resident AUTOINIT v1 rev1, pri 0; name->0x1e id->0x2e init->0x64 |
| 0x1d | name `xpkLIN4.library` (stray 'd' byte at +0x1d before name ptr target) |
| 0x2e | idstr `$VER: xpkLIN4 V1.1 (1 Oct 2013) by Gerhard Tuenkler` |
| 0x64 | InitTable: dsz=0x26, functab->0x94, datatab->0x74, initfn->0xac |
| 0x94 | word-offset functab: ffff, 10 entries, ffff |
| 0xd2c..0xdaa | mode table: minimal/normal/maximal records + `LINO4` chunk id |
| 0xdb0.. | PackerInfo strings (Lino4 V1.1, Comressing[sic]/Expanding/Compressed/Expanded) |
