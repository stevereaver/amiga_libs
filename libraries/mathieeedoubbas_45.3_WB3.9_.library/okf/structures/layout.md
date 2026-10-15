---
file: layout
---
# mathieeedoubbas 45.3 layout

File 3604B. Single CODE hunk 0x373 longs (3532B @0x20).
Tail: RELOC32 groups ->h0, HUNK_END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #-1,d0 / rts` stub |
| 0x04 | Resident: flags 0x01 (COLDSTART), ver 45, type 9; name->0x1e id->0x36 init->0x7a |
| 0x1e/0x36 | name/idstr ('mathieeedoubbas.library 45.3 (23.11.2000)') |
| 0x62 | 'fpsp.resource' string |
| 0x7a | init: `movel a0,$17e` seglist stash; OpenResource('fpsp.resource'); functab select (fpsp->0x1c8 / attn-bit4->0x1a4 / default->0x180); MakeLibrary(dsz 0x40, datatab->0xf2, initfn 0); fills lib_Name/IdString@34/38, lib_Flags@22=attn&0x10, lib_SysBase@28, fpsp res@60; AddLibrary |
| 0x180/0x1a4/0x1c8 | three word-offset functabs (0xffff bookends), 16 vectors each |
