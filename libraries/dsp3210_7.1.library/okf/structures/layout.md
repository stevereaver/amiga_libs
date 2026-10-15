---
type: Structures
title: dsp3210 7.1 layout
---

# dsp3210 7.1 layout

File 4648B (0x1228). HUNK_HEADER: 1 hunk, first=last=0,
hunk0 size 0x478 longs. Single HUNK_CODE 0x478 longs
(4576B body @ file 0x20). Tail: RELOC32 — 5 offsets
->h0 (0x6, 0xa, 0x12, 0x16, 0x1a, descending; the resident
pointer fields only), HUNK_END. No other hunks, no overlay.
Identical container to 7.0.

## hunk0

| off   | contents |
|-------|----------|
| 0x00  | `moveq #-1,d0 / rts` module-entry stub (same as 7.0) |
| 0x04  | Resident: 0x4afc, matchtag->+0x04, endskip->+0x11e0, flags 0x00 (COLDSTART/non-AUTOINIT), ver 7, type 9 (NT_LIBRARY), pri 0, name->+0x1e, id->+0x34, init->+0x9c |
| 0x1e  | `dsp3210.library` |
| 0x2e  | `$VER: ` (6B prefix, not referenced) |
| 0x34  | `dsp3210.library 7.1 (12.12.2021)\r\n` — the rt_IdString target; 34B, pad 0x56-0x57 |
| 0x58  | `dos.library` (was 0x56 in 7.0; +2 after the longer idstr, realigned by the lost 2 pad bytes before DSPCOMPAT) |
| 0x64  | `DSPCOMPAT` |
| 0x70  | `Written by Thomas Winischhofer (A10001986)` |
| 0x9c  | rt_Init bootstrap: regs; execbase via `moveal 4,a6`; MakeLibrary(functab->+0x172 word-offsets, dtab=0, initfn->+0xc8, dsize 0x2c, seg) then AddLibrary; returns 1 |
| 0xc8  | initfn: fills lib node — type/name/idstr pointers, `movew #7,lib@(20)` (lib_Version=7) and **`movew #1,lib@(22)` (lib_Revision=1)** — was `clrw` (rev 0) in 7.0, +2B, everything after shifts +2 |
| 0x102 | Open / 0x112 Close / 0x12c Expunge / 0x16e reserved stub (7.0 +2) |
| 0x172 | word-offset functab: `ffff` marker + 15 words + `ffff` — **bytes identical to 7.0's table** (offsets are table-relative and every vector moved +2 together) |
| 0x194 | DSPCalcLen; 0x222 DSPRelocate; 0x22c error/alloc helper |
| 0x96a | strcmp helper; error tails -1/-3/-5/-11/-21/-23/-31 at 0x942-0x968 |
| 0x980 | -48 entry (d4=0x10001); 0x98c -78 entry (d4=0x10003); shared DSP-op body 0x996-0xb51 |
| 0xb52 | -54 magic-guarded block op (status protocol) |
| 0xb9a | -66 entry: container-cookie (0x00fc2011) keyed node free, else block free |
| 0xbe2 | block-free subroutine (cookie 0x32102011, -1/0 status) |
| 0xc12 | -90 free-all: container list drain via exec RemHead, else NULL-array free |
| 0xc64 | -60 name lookup: container-aware (obj+4 table, then node+12 tables), else array-of-tables walk |
| 0xcf2 | -72 d32 blob dump/scanner (validates magic 0x0166/0x6601) |
| 0xee6 | -84 status check + lazy-open helpers 0xefa (open `dos.library` via exec -552 into base+0x26), 0xf18 (close via -414), 0xf32 (DSPCOMPAT probe via dos -906, sets base+0x2a/0x2b) |
| 0xf4e | **7.1 change:** `moveq #0,d4` inside the DSPCOMPAT probe — 7.0 had `movel #0x100,d4` (-4B; everything 0xf50-0x1059 sits at 7.0-2) |
| 0xf66 | blob endianness/magic fixups (0x0166 / 0x2b38 / 0x382b cookies), second at 0xf84 — in the -2 window |
| 0xfe8 | DSP register-name table: 12 word offsets (0x1a..0x6a rel 0xfe8) + `0000` terminator @0x1000, then records `{u16 reg; char name[]}` at 0x1002 — 0x404 `ibuf`, 0x408 `obuf`, 0x40c `ioc`, 0x413 `tcon`, 0x414 `timer`, 0x41b `bioc`, 0x41e `bio`, 0x420 `idp`, 0x424 `odp`, 0x42a `icnt`, 0x42e `ocnt`, 0x433 `dmac` — **new explicit `0000` terminator at 0x105a** (7.0 ran straight into code after the pad byte); code realigns to 7.0 offsets at 0x105c |
| 0x10e6 | loader alloc tail: size +=16 (+12 more if container cookie), AllocMem(0x10001) via exec -198, {0x32102011,size} block header, then node AddTail into container MinList or NULL-array append |
| 0x11de | final `rts` — body ends with NO pad bytes |

## Shift map vs 7.0

| 7.0 range | 7.1 shift | cause |
|-----------|-----------|-------|
| 0x56-0x63 | +2 | idstr one char longer + extra pad |
| 0x64-0x9b | 0 | two pad bytes after `dos.library` consumed |
| 0xea-0xf4b | +2 | `clrw` -> `movew #1` in initfn (+2) |
| 0xf52-0x105b | -2 | `movel #0x100,d4` -> `moveq #0,d4` (-4) |
| 0x105c-end | 0 | +2 terminator word on the name records |

Base size passed to MakeLibrary is 0x2c (44); base+0x26 holds
the secondary library pointer, base+0x2a/0x2b are flag bytes.

## Container object (unchanged from 7.0)

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
