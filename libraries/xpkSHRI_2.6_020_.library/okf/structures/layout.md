---
file: layout
---
# xpkSHRI 2.6(020) layout

File 4228B. Single hunk0 CODE 0x3fd longs (4084B @0x20).
Tail: RELOC32 — 23 ->h0 entries (incl. functab/probe slots and
mid-file mode-table pointers 0xe06..0xf26), END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #-1,d0 / rts` stub (also the functab 0-hole target) |
| 0x04 | Resident: flags 0x80 AUTOINIT, ver 2; name->+0x1e id->+0x2e init->+0x64 |
| 0x1e | 'xpkSHRI.library' |
| 0x2e | '$VER: xpkSHRI V2.6 (1 Oct 2013) by Matthias Meixner\r\n' |
| 0x64 | InitTable: dsize 0x26, ftab->+0x94, dtab->+0x74, initfn->+0xac |
| 0x74 | InitStruct byte-cmd datatab (ln_Type/name/ver=2/rev=6/idstr) |
| 0x94 | word-offset functab: ffff + 10 words + ffff |
| 0xac | initfn: seglist store, AttnFlags bit-1 test — clear -> +0 stub |
| 0xdbe | packer-info/mode tables + strings to 0xff4 |
