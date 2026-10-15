---
file: layout
---
# xpkSHR3 3.0(020) layout

File 4232B. Single hunk0 CODE 0x3fe longs (4088B @0x20).
Tail: RELOC32 — 23 ->h0 entries (resident/initdatatab/functab
ptrs, packer-info string ptrs 0xe0a..0xe3e, mode-desc next ptrs
0xe5a..0xf2a), END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #0,d0 / rts` stub (also the functab 0-hole target) |
| 0x04 | Resident: flags 0x80 AUTOINIT, ver 3; name->+0x1e id->+0x2e init->+0x64 |
| 0x1e | 'xpkSHR3.library' |
| 0x2e | '$VER: xpkSHR3 V3.0 (1 Oct 2013) by Matthias Meixner\r\n' |
| 0x64 | InitTable: dsize 0x26, ftab->+0x94, dtab->+0x74, initfn->+0xac |
| 0x74 | InitStruct byte-cmd datatab (ln_Type=9/ln_Name/flags=6/ver=3/rev=0/idstr) |
| 0x94 | word-offset functab: ffff + 10 words + ffff |
| 0xac | initfn: seglist store, AttnFlags bit-1 test — clear -> +0 stub |
| 0xdc2 | tail data: 14-word match-offset class table, 9-long hash-size table @0xdde, XpkPackerInfo @0xe02, 7 mode descs @0xe5a..0xf54 (stride 0x2a), strings, ends 0xff8 |
