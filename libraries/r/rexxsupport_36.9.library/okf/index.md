# rexxsupport.library 36.9 — OKF index

Commodore's **ARexx support function library**
(`rexxsupport 36.9 (02-NOV-90)`): provides 23 ARexx host
commands for memory peeking/allocation, DOS file operations,
Exec list inspection, and inter-process RexxMsg packet/port
manipulation.  Successor of `rexxsupport 34.9 (01-DEC-89)`
(see `libraries/rexxsupport_34.9.library/`).

- Binary: `binary/rexxsupport_36.9.library` — 2528 bytes, m68000.
- Reconstruction: `source/rexxsupport.s` (hand-written 68k
  assembly) + `source/Makefile`, built with
  `m68k-amigaos-gcc -m68000 -nostdlib -s`; result is
  **byte-identical** to the original (2528 bytes, single CODE
  hunk + same 9 relocations).
- Oracle: `work/oracle.py` (main battery) and
  `work/failtest.py` (failure-injection matrix), both run under
  `machine68k` against original and reconstruction.

## Hunk layout

| offset | contents |
|--------|----------|
| +0x000 | `moveq #0,d0; rts` prefix stub |
| +0x004 | RomTag: RTC_MATCHWORD, AUTOINIT(0x80), ver 36, NT_LIBRARY, pri 0; pad word is `4e71` (nop) |
| +0x020 | InitTable {dsz=0x2e, ftab→0x30, dtab→0x3e, ifn→0x58} |
| +0x030 | functab: word-offset flavour (-1, 5 offsets, -1) |
| +0x03e | datatab (8-bit-offset InitStruct forms; **no** @24 IdStr record) |
| +0x058 | initfn (stores SysBase/seglist/**IdString**, opens rexxsyslib **any version**) |
| +0x082..+0x0de | lifecycle (Open/Close/Expunge) + null stub |
| +0x0e0..+0x21e | dispatcher, name lookup, result packaging, err exits |
| +0x220..+0x384 | command table (23 records) + jump table + helpers |
| +0x384..+0x942 | 23 command handlers + SHOWDIR/SHOWLIST helpers |
| +0x942.. | strings: libname, idstr, "rexxsyslib.library", sf tables |

Hunks: single CODE hunk 0x988 bytes; 9 RELOC32 entries at
offsets `6 a 12 16 1a 24 28 2c 44` (resident pointers +
InitTable/datatab pointers — identical in the rebuild;
34.9's 10th reloc at `56` is gone with the IdStr record).

## Vectors (5)

| LVO | Target | Function |
|-----|--------|----------|
| -6  | +0x82  | LibOpen (opencnt++, clear DELEXP) |
| -12 | +0x90  | LibClose (deferred-expunge path; falls into Expunge) |
| -18 | +0x9e  | LibExpunge (deferred when open; Remove+CloseLib+FreeMem) |
| -24 | +0xdc  | null stub (`moveq #0,d0; rts`) |
| -30 | +0xe0  | ARexx command dispatcher |

See `functions/vectors.md` for the dispatcher contract and the
23-command table, `structures/layout.md` for the request
block/task block/argstring/RexxMsg/port-node layouts, and
`findings/deltas.md` + `findings/defects.md` for the 34.9→36.9
changes and the confirmed quirks.

## Exported ARexx commands

`NEXT NULL BADDR DELAY REPLY DELETE FORBID GETARG GETPKT OFFSET
PERMIT RENAME STATEF FORWARD FREEMEM MAKEDIR SHOWDIR TYPEPKT
WAITPKT ALLOCMEM OPENPORT SHOWLIST CLOSEPORT` — names are
matched length 4–9, case-insensitively.  Command set, packed
command table, index tables and every handler body are
instruction-identical to 34.9 (only PC-relative displacements
shifted).

## Deltas vs 34.9 (summary — see findings/deltas.md)

1. `lib_IdString` moved out of datatab into initfn code
   (`lea _idstr(pc),a0; movel a0,24(a5)`), removing one
   InitStruct record and one relocation.
2. initfn calls `OpenLibrary("rexxsyslib.library", 0)` — any
   version — instead of requiring v36.
3. Dispatcher rework: `a6` is RexxSysBase for the whole body
   (`exg a4,a6` at entry and around the handler call); a
   400-byte scratch argstring is allocated via rxs-126 as the
   `a3` result buffer and always freed via rxs-132 on exit;
   `*T+136` is no longer used; `jtab` base is the pre-jsr
   `exg` (brief-extension disp -4 vs -2).
4. Result-string contract unchanged: d0 = error code,
   a0 = result argstring; flags in high bits of d7.

## Verification status

- **File identity**: rebuild `source/rexxsupport.library` is
  `cmp`-identical to `binary/rexxsupport_36.9.library`
  (hunk header, code hunk, reloc table, all strings).
- machine68k oracle: **identical observable behavior** for
  every test on both binaries — library header/vectors/data,
  init (incl. missing-rexxsyslib → init fail), all 23 commands,
  every result mode (raw/numeric/boolean/empty), dispatch
  errors (1=unknown name, 17=arg count, 18=conversion/handle),
  packet and port operations, SHOWLIST exec-list and DOS
  devlist enumeration, close/deferred-expunge/expunge
  lifecycle, and a failure matrix (AllocMem fail, DOS/Lock/
  Examine fail, port-node create fail, append/flatten fail,
  unknown ports, invalid handles) — including the per-dispatch
  `argstr 400` scratch alloc + `delarg` free in the call log.
