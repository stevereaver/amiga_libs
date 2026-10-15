---
type: Structures
title: dsp3210 7.0 layout
---

# dsp3210 7.0 layout

File 4648B (0x1228). HUNK_HEADER: 1 hunk, first=last=0,
hunk0 size 0x478 longs. Single HUNK_CODE 0x478 longs
(4576B body @ file 0x20). Tail: RELOC32 — 5 offsets
->h0 (0x6, 0xa, 0x12, 0x16, 0x1a, descending; the resident
pointer fields only), HUNK_END. No other hunks, no overlay.

## hunk0

| off   | contents |
|-------|----------|
| 0x00  | `moveq #-1,d0 / rts` module-entry stub (returns -1; same as 6.0) |
| 0x04  | Resident: 0x4afc, matchtag->+0x04, endskip->+0x11e0, flags 0x00 (COLDSTART/non-AUTOINIT), ver 7, type 9 (NT_LIBRARY), pri 0, name->+0x1e, id->+0x34, init->+0x9c |
| 0x1e  | `dsp3210.library` |
| 0x34  | `$VER: dsp3210.library 7.0 (29.8.2021)\r\n` |
| 0x56  | `dos.library` |
| 0x64  | `DSPCOMPAT` |
| 0x70  | `Written by Thomas Winischhofer (A10001986)` |
| 0x9c  | rt_Init bootstrap: regs; execbase via `moveal 4,a6`; MakeLibrary(functab->+0x170 word-offsets, dtab=0, initfn->+0xc8, dsize 0x2c, seg) then AddLibrary; returns 1 |
| 0xc8  | initfn: fills lib node — type/name/idstr pointers, `movew #7,lib@(20)` (lib_Version=7) |
| 0x100 | Open / 0x110 Close / 0x12a Expunge / 0x16c reserved |
| 0x170 | word-offset functab: `ffff` marker + 15 words + `ffff` (same as 6.0) |
| 0x192 | DSPCalcLen; 0x220 DSPRelocate; DSP d32 loader/reloc/exec routines after; 0x22a error/alloc helper |
| 0x968 | strcmp helper (was 0x978); error tails -1/-3/-5/-11/-21/-23/-31 at 0x940-0x966 (was 0x950-0x976) |
| 0x97e | -48 entry (d4=0x10001); 0x98a -78 entry (d4=0x10003); shared DSP-op body 0x994-0xb4f |
| 0xb50 | -54 magic-guarded block op (status protocol, returns saved-a6/0/-60-result) |
| 0xb98 | -66 entry: container-cookie (0x00fc2011) keyed node free, else block free |
| 0xbe0 | block-free subroutine = 6.0's -66 body verbatim (cookie 0x32102011, -1/0 status) |
| 0xc10 | -90 free-all: container list drain via exec RemHead, else NULL-array free |
| 0xc62 | -60 name lookup: container-aware (obj+4 table, then node+12 tables), else array walk |
| 0xcf0 | -72 d32 blob dump/scanner (same length as 6.0, shifted +0xbc) |
| 0xee4 | -84 status check + lazy-open helpers 0xef8 (open `dos.library` via exec -552 into base+0x26), 0xf16 (close via -414), 0xf30 (DSPCOMPAT probe via dos -906, sets base+0x2a/0x2b) |
| 0xf68 | blob endianness/magic fixups (0x0166 / 0x2b38 / 0x382b cookies) |
| 0xfea | DSP register-name table: 12 word offsets (0x1a..0x6a rel 0xfea) then records `{u16 reg; char name[]}` at 0x1004 — 0x404 `ibuf`, 0x408 `obuf`, 0x40c `ioc`, 0x413 `tcon`, 0x414 `timer`, 0x41b `bioc`, 0x41e `bio`, 0x420 `idp`, 0x424 `odp`, 0x42a `icnt`, 0x42e `ocnt`, 0x433 `dmac` — `0000` terminator at 0x105c, no pad (6.0: table at 0xf32) |
| 0x10e6 | loader alloc tail: size +=16 (+12 more if container cookie), AllocMem(0x10001) via exec -198, {0x32102011,size} block header, then node AddTail into container MinList or NULL-array append |
| 0x11de | final `rts` — body ends with NO pad bytes (6.0 had a 2-byte pad) |

Base size passed to MakeLibrary is 0x2c (44); base+0x26 holds
the secondary library pointer, base+0x2a/0x2b are flag bytes.

## Container object (new in 7.0)

Longword cookie `0x00fc2011` at +0 marks a container:

| off  | field |
|------|-------|
| +0   | cookie 0x00fc2011 |
| +4   | NULL-terminated pointer-array table (scanned first by -60) |
| +8   | embedded MinList (lh_Head/lh_Tail/lh_TailPred) — NewList-inited on demand |

Nodes linked into +8: +0/+4 ln_Succ/ln_Pred, +8 key pointer
(matched against a1 by -66), +12 payload table (scanned by -60).
Blocks still carry the 0x32102011 cookie + size longwords at
block-8 for the guarded frees.
