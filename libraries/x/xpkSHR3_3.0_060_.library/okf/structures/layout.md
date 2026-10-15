---
file: layout
---
# xpkSHR3 3.0(060) layout

File 4280B (+48B vs the 020 build). Single hunk0 CODE 0x40a longs
(4136B @0x20; 020: 0x3fe/4088B). Tail: RELOC32 — 23 ->h0 entries
(head ptrs @0x6..0x8c identical to 020; the 14 tail ptrs all +0x2e:
packer-info string ptrs 0xe38..0xe6c, mode-desc next ptrs
0xe88..0xf58), END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #0,d0 / rts` stub (also the functab 0-hole target) |
| 0x04 | Resident: flags 0x80 AUTOINIT, ver 3; name->+0x1e id->+0x2e init->+0x64 |
| 0x1e | 'xpkSHR3.library' |
| 0x2e | '$VER: xpkSHR3 V3.0 (1 Oct 2013) by Matthias Meixner\r\n' |
| 0x64 | InitTable: dsize 0x26, ftab->+0x94, dtab->+0x74, initfn->+0xac |
| 0x74 | InitStruct byte-cmd datatab (ln_Type=9/ln_Name/flags=6/ver=3/rev=0/idstr) — byte-identical to 020 |
| 0x94 | word-offset functab: ffff + 10 words + ffff (entry -54 offset 0x06ae vs 020's 0x069e) |
| 0xac | initfn: seglist store, AttnFlags bit-1 test — clear -> +0 stub (byte-identical to 020) |
| 0xdf0 | tail data: 14-word match-offset class table, 9-long hash-size table @0xe0c, XpkPackerInfo @0xe30, 7 mode descs @0xe88..0xf82 (stride 0x2a), strings, ends 0x1028 |

Code region 0xac-0xdf0 (+0x2e longer than 020's 0xac-0xdc2).
XpkPackerInfo @0xe30: ver=1 libv=3 masterv=2 modesv=0,
name 'Shrink' @0xfac, lname 'Shrink 020-060 V3.0' @0xfb3,
desc @0xfc7, sign 'SHR3', flags 0x28009, max 0x7fffffff, min 0,
def 0x7ffe, defmode 100, modedesc->0xe88. Mode descs upto
14/28/42/56/70/84/100, mflags 1, pspd 10..7, uspd 20..24.
