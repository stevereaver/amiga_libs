# rexxsupport.library 34.9 — OKF index

Commodore's **ARexx support function library**
(`rexxsupport 34.9 (01-DEC-89)`): provides 23 ARexx host
commands for memory peeking/allocation, DOS file operations,
Exec list inspection, and inter-process RexxMsg packet/port
manipulation.  It is the library behind `rexxsupport.library`
on the Workbench 2.04/2.05 disks; the WB2.05 disk copy
(`rexxsupport_34.9(WB2.05+).library`) is byte-identical
(md5 `27237403790d4638d8544f09f079d7f7`).

- Binary: `binary/rexxsupport_34.9.library` — 2524 bytes, m68000.
- Reconstruction: `source/rexxsupport.s` (hand-written 68k
  assembly) + `source/Makefile`, built with
  `m68k-amigaos-gcc -m68000 -nostdlib -s`; result is 2528
  bytes (single CODE hunk + same 10 relocations).
- Oracle: `work/oracle.py` (main battery) and
  `work/failtest.py` (failure-injection matrix), both run under
  `machine68k` against original and reconstruction.

## Hunk layout (original)

| offset | contents |
|--------|----------|
| +0x000 | `moveq #0,d0; rts` prefix stub |
| +0x004 | RomTag: RTC_MATCHWORD, AUTOINIT(0x80), ver 34, NT_LIBRARY, pri 0 |
| +0x020 | InitTable {dsz=0x2e, ftab→0x30, dtab→0x3e, ifn→0x5e} |
| +0x030 | functab: word-offset flavour (-1, 5 offsets, -1) |
| +0x03e | datatab (8-bit-offset InitStruct forms) |
| +0x05e | initfn (stores SysBase+seglist, opens rexxsyslib v36) |
| +0x080..+0x0dc | lifecycle (Open/Close/Expunge) + null stub |
| +0x0de..+0x20a | dispatcher, name lookup, result packaging, err exits |
| +0x20c..+0x36a | command table (23 records) + jump table + helpers |
| +0x36a..+0x8fe | 23 command handlers + SHOWDIR/SHOWLIST helpers |
| +0x8fe.. | strings: libname, idstr, "rexxsyslib.library", sf tables |

Hunks: CODE hunk 0x970 bytes + empty BSS hunk; 10 RELOC32
entries at offsets `6 a 12 16 1a 24 28 2c 44 56` (residnt
pointers + InitTable/datab pointers — identical in the rebuild).

## Vectors (5)

| LVO | Target | Function |
|-----|--------|----------|
| -6  | +0x80  | LibOpen (opencnt++, clear DELEXP) |
| -12 | +0x8e  | LibClose (deferred-expunge path) |
| -18 | +0x9c  | LibExpunge (deferred when open; Remove+CloseLib+FreeMem) |
| -24 | +0xda  | null stub (`moveq #0,d0; rts`) |
| -30 | +0xde  | ARexx command dispatcher |

See `functions/vectors.md` for the dispatcher contract and the
23-command table, `structures/layout.md` for the request
block/task block/argstring/RexxMsg/port-node layouts, and
`findings/defects.md` for the confirmed quirks.

## Exported ARexx commands

`NEXT NULL BADDR DELAY REPLY DELETE FORBID GETARG GETPKT OFFSET
PERMIT RENAME STATEF FORWARD FREEMEM MAKEDIR SHOWDIR TYPEPKT
WAITPKT ALLOCMEM OPENPORT SHOWLIST CLOSEPORT` — names are
matched length 4–9, case-insensitively.

## Verification status

machine68k oracle: **byte-identical observable behavior** for
every test on both binaries — library header/vectors/data,
init (incl. missing-rexxsyslib → init fail), all 23 commands,
every result mode (raw/numeric/boolean/empty), dispatch errors
(1=unknown name, 17=arg count, 18=conversion/handle), packet
and port operations, SHOWLIST exec-list and DOS devlist
enumeration, close/deferred-expunge/expunge lifecycle, and a
failure matrix (AllocMem fail, DOS/Lock/Examine fail, port-node
create fail, append/flatten fail, unknown ports, invalid
handles).  The only observable difference is the stale `a0`
leftover on an unknown-name dispatch — a pointer into the
command table whose absolute value differs by code layout.
