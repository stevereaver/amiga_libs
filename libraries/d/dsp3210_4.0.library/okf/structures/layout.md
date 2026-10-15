---
file: layout
---
# dsp3210 4.0 layout

File 4340B. Single hunk0 CODE 0x42b longs (4268B @0x20).
Tail: RELOC32 — 5 ->h0 (resident pointer fields only), END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #-1,d0 / rts` stub |
| 0x04 | Resident: flags 0x00 COLDSTART, ver 4; name->+0x1e
       | id->+0x34 init->+0x9c |
| 0x1e | 'dsp3210.library' / '$VER: dsp3210.library 4.0
       | (15.7.2021)' / 'dos.library' / 'DSPCOMPAT' /
       | 'Written by Thomas Winischhofer (A10001986)' |
| 0x9c | rt_Init: regs, execbase via `moveal 4,a6`,
       | MakeLibrary(ftab->+0x170 word-offsets, dtab=0,
       | initfn->+0xc8, dsize 0x2c, seg) + AddLibrary |
| 0xc8 | initfn: fills lib node (ver 4, name/idstr ptrs) |
| 0x100 | Open / 0x110 Close / 0x12a Expunge |
| 0x170 | word-offset functab: ffff marker + 14 words + ffff |
| ~0x190+ | DSP d32 loader/reloc/exec routines |
