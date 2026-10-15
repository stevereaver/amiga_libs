# rexxserdev.library 5.02 — OKF index

Joseph M. Stivaletta's **ARexx serial-device function library**
(`rexxserdev 5.02 (24 March 1993)`): registers 14 `Ser*` ARexx
functions that wrap `serial.device` behind open/close handles.
Aminet: `util/rexx/rxser502` (the `RexxSerDevFix` package later
patched a real FreeMem bug — see `findings/defects.md`).

- Binary: `binary/rexxserdev_5.02.library` — 2412 bytes, m68000.
- Reconstruction: `source/` — C API (`rexxserdev.c`) + AutoInit
  glue/lifecycle/dispatcher (`rexxserdev_lib.s`).

## Hunk layout (original)

Single CODE hunk, declared 0x223 words (0x88c bytes).  Layout:

| offset | contents |
|--------|----------|
| +0x000 | `moveq #0,d0;rts` prefix stub (entry/exec prefix) |
| +0x004 | RomTag: AUTOINIT(0x80), ver 5, NT_LIBRARY, pri 0 |
| +0x020 | InitTable {dsz=0x42, ftab→0x30, dtab→0x48, ifn→0x68} |
| +0x030 | functab: 5 absolute longs + -1 |
| +0x048 | datatab (8-bit-offset InitStruct forms) |
| +0x068 | initfn (opens rexxsyslib v0 + utility v37) |
| +0x0a8..+0x174 | lifecycle (Open/Close/Expunge) + null + dispatcher |
| +0x176..+0x7d8 | 14 API functions + io/obj helpers + teardown chains |
| +0x6f8..+0x758 | strings: utility/rexxserdev/idstr/rexxsyslib/"1"/"0" |
| +0x75c | apitab (14 function ptrs) |
| +0x794 | nametab (14 name ptrs) |
| +0x7cc..+0x858 | name strings |

## Vectors (5)

| LVO | Target  | Function                                |
|-----|---------|-----------------------------------------|
| -6  | +0xa8   | LibOpen (opencnt++, clear DELEXP)       |
| -12 | +0xb6   | LibClose (deferred expunge)             |
| -18 | +0xca   | LibExpunge (correct, returns seglist)   |
| -24 | +0x11a  | null stub (`moveq #0,d0;rts`)           |
| -30 | +0x120  | ARexx dispatcher                        |

The dispatcher takes `a0` = request block (`+40` = function name
argstring, `+44..` = args) and `a6` = lib base.  It walks the
14-entry `nametab` comparing via `utility.library` `Stricmp`
(-162); on a miss it returns `d0=1`.  For table indices 0–10
(all functions except SerOpen/SerLibBase/SerID) it first resolves
arg0 (`msg+44`) through the private rexxsyslib -300 vector into an
object pointer in `a2` — a NULL arg yields `d0=12`.  On dispatch:
`a2`=object, `a5`=lib base, `d4`=request; the callee returns the
reply argstring in `a1` and an error code in `d0`.

## Exported ARexx functions

See `functions/vectors.md` for the full table and
`structures/layout.md` for private data / SerObj / IOExtSer /
request-block layouts.

## Verification status

machine68k oracle (`work/oracle.py`): **byte-identical** observable
behavior across the full battery — library header, init opens +
imports, all 14 dispatcher entries, SerOpen/Read/Write/Query/
SetParms/Clear/Reset/Break/Start/Stop/Flush/Close, error strings,
lifecycle + deferred expunge, and a 4-case failure matrix
(`work/edge.py`: missing libraries, OpenDevice failure, DoIO
errors, parity/flag matrix) — all matching the original.
