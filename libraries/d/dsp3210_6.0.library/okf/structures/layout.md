---
type: Structures
title: dsp3210 6.0 layout
---

# dsp3210 6.0 layout

File 4396B (0x112c). HUNK_HEADER: 1 hunk, first=last=0,
hunk0 size 0x439 longs. Single HUNK_CODE 0x439 longs
(4324B body @ file 0x20). Tail: RELOC32 — 5 offsets
->h0 (0x6, 0xa, 0x12, 0x16, 0x1a, descending; the resident
pointer fields only), HUNK_END. No other hunks, no overlay.

## hunk0

| off   | contents |
|-------|----------|
| 0x00  | `moveq #-1,d0 / rts` module-entry stub (returns -1; 5.0 returned 0) |
| 0x04  | Resident: 0x4afc, matchtag->+0x04, endskip->+0x10e2, flags 0x00 (COLDSTART/non-AUTOINIT), ver 6, type 9 (NT_LIBRARY), pri 0, name->+0x1e, id->+0x34, init->+0x9c |
| 0x1e  | `dsp3210.library` |
| 0x34  | `$VER: dsp3210.library 6.0 (20.8.2021)\r\n` |
| 0x56  | `dos.library` |
| 0x64  | `DSPCOMPAT` |
| 0x70  | `Written by Thomas Winischhofer (A10001986)` |
| 0x9c  | rt_Init bootstrap: regs; execbase via `moveal 4,a6`; MakeLibrary(functab->+0x170 word-offsets, dtab=0, initfn->+0xc8, dsize 0x2c, seg) then AddLibrary; returns 1 |
| 0xc8  | initfn: fills lib node — type/name/idstr pointers, `movew #6,lib@(20)` (lib_Version=6) |
| 0x100 | Open / 0x110 Close / 0x12a Expunge / 0x16c reserved |
| 0x170 | word-offset functab: `ffff` marker + 15 words + `ffff` (5.0: 14 words) |
| 0x192 | DSPCalcLen; 0x220 DSPRelocate; DSP d32 loader/reloc/exec routines after |
| 0xba2 | reworked -66 guarded free (-1/0 status); 0xbd4 new -90 pointer-array free; 0xbf6 list walker |
| 0xf32 | DSP register-name table: 12 word offsets (0x1a..0x6a) then records `{u16 reg; char name[]}` — 0x404 `ibuf`, 0x408 `obuf`, 0x40c `ioc`, 0x413 `tcon`, 0x414 `timer`, 0x41b `bioc`, 0x41e `bio`, 0x420 `idp`, 0x424 `odp`, 0x42a `icnt`, 0x42e `ocnt`, 0x433 `dmac` — then `0000` terminator, NO pad bytes (5.0 had +2 pad) |
| 0xe3c | lazy-open helper for secondary lib (exec -552 `OldOpenLibrary`-style probe of base+0x26, name `dos.library`@+0x56; stores result at base+0x26) |
| 0xeac / 0xeca | blob endianness/magic fixups (0x0166 / 0x2b38 / 0x382b cookies) |

Base size passed to MakeLibrary is 0x2c (44); base+0x26 holds
the secondary library pointer, base+0x2a/0x2b are flag bytes.
