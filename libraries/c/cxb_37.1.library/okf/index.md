---
type: Library
title: cxb.library 37.1 (Captain Crossbones / FR-SoftWorks)
description: >-
  cxb.library (20.01.98) -- a small SAS/C utility library
  that registers each opener in a task-indexed context
  table and lazily opens dos/intuition/graphics for it.
  Four public functions: a Lock+Examine file probe, two
  integer multiplies, and an EasyRequestArgs helper whose
  static EasyStruct carries a "(C) 1998 by Captain
  Crossbones" gadget text.  Uses a CUSTOM flag byte at
  base+34 (struct Library's lib_SegList slot) for the
  delayed-expunge bit; the real seglist is at base+44.
timestamp: 2026-10-28T00:00:00Z
---

# cxb.library 37.1

A ~1.4KB private utility library by Captain Crossbones of
FR-SoftWorks (dated 20 Jan 1998).  Its whole job is to give
each *opening task* a private 0x638-byte context that holds
lazily-opened dos/intuition/graphics library bases, so the
four public functions can be re-entrant per task.

## Binary facts

- 1388 bytes, single CODE hunk, SAS/C build
- sha256: `049a71c542f196806e4eee85243768f8932a1e1602cc94a0779746d782e1681d`
- RomTag: RTF_AUTOINIT, ver 37, NT_LIBRARY,
  RT_INIT -> InitTable (dataSize 0x430)
- FUNCTABLE = 8 LONG-address vectors (then two `0xffff`)
- idstring "cxb.library 37.1 (20.01.98)"

## Public vectors / LVOs

| LVO | name           | semantics                                  |
|-----|----------------|--------------------------------------------|
|  -6 | Open           | register task context, opencnt++           |
| -12 | Close          | free task context, opencnt--               |
| -18 | Expunge        | Remove+FreeMem, or set DELEXP if open      |
| -24 | Reserved       | returns 0                                  |
| -30 | cxbFileInfo    | Lock+Examine+UnLock -> 0 ok / -1 fail      |
| -36 | cxbMult        | d0*d1  (32-bit multiply)                   |
| -42 | cxbMult209     | d0*209                                     |
| -48 | cxbRequest     | EasyRequestArgs on a static EasyStruct     |

## Library base layout (dataSize 0x430)

| off | field                                          |
|-----|------------------------------------------------|
|0x00 | `struct Library` (incl. OpenCnt @ 32)          |
|0x22 | **custom** flag byte -- bit3 = delayed-expunge |
|0x24 | SysBase (stored by INITFUNCTION)               |
|0x2c | seglist (NOT the standard lib_SegList @ 0x22)  |
|0x30 | 128 {task,ctx} context-slot longs (512B shown) |

## Per-opener context (0x638, AllocMem'd)

Referenced through `a4 = ctx + 0x40`; the fields live in the
0x40-byte header *below* a4 (negative a4 offsets):

| a4 off | field                          |
|--------|--------------------------------|
| -52    | graphics.library base          |
| -48    | intuition.library base         |
| -44    | dos.library base               |
| -40    | SysBase                        |
|  -4    | saved caller sp                |
| -64    | the 0x638 block (for FreeMem)  |

## External calls

- exec -198 AllocMem, -210 FreeMem, -252 Remove,
  -132 Forbid, -138 Permit, -552 OpenLibrary,
  -414 CloseLibrary; ThisTask read via `SysBase->ThisTask`
  (offset 276) off absolute `4.W`
- dos (per-context base): -84 Lock, -90 UnLock, -102 Examine
- intuition (per-context base): -588 EasyRequestArgs

## Reconstruction

- `source/cxb_lib.s` -- RomTag, InitTable (word-offset
  datatab replicated byte-for-byte), INITFUNCTION, 8-long
  FUNCTABLE, static EasyStruct + strings, `__mulsi3`
- `source/cxb.c` -- framework + all four public functions
- builds to a single CODE-hunk `cxb.library` with the m68k
  cross toolchain; datatab, functab and init match the
  original byte-for-byte (modulo pointer addresses)
