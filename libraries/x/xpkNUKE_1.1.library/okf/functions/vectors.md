---
type: Function
title: xpkNUKE 1.1 vector map
timestamp: 2026-10-15T00:00:00Z
---

# Vectors (offsets relative to hunk0 start)

Functab at hunk0+0xaa4: 10 absolute longwords + 0xffffffff
terminator (NOT the later word-offset flavour).

| LVO  | offset | function |
|------|--------|----------|
|  -6  | 0x0d2  | LibOpen — opencnt (lib+0x20)++, bclr #3 lib+0xe, ret lib |
| -12  | 0x0ee  | LibClose — opencnt--; if 0 and DELEXP bit -> Expunge |
| -18  | 0x118  | LibExpunge — bset #3 lib+0xe; if open ret 0; else jsr 0xaec (noop), seglist in d7, exec Remove(lib)+FreeMem(lib-neg, neg+pos=436) ret seglist |
| -24  | 0x000  | LibNull — moveq #0,d0; rts (also the hunk entry stub) |
| -30  | 0x17c  | XpksPackerInfo — returns a0 = lib+0xfe (XpkInfo copy) |
| -36  | 0x244  | XpksPackChunk — pack entry |
| -42  | 0x18c  | XpksPackFree — frees ctx tables; does NOT clear xsp_Sub[0] |
| -48  | 0x308  | stub — saves a2/a4, ret d0=0 |
| -54  | 0x31a  | XpksUnpackChunk — unpack entry, always ret 0 |
| -60  | 0x35c  | stub — saves regs, ret stale d0 (no state to free) |

InitFn at hunk0+0x20 (called by AUTOINIT): fills lib header fields
(type=9, name=code+0xad0, flags=6, ver=1, rev=0, idstr=code+0xae0),
seglist -> lib+0x22 (34); memcpy data hunk -> lib+0x3a (284B);
self-relocate 8 longs via table at data+0x120; jsr 0xaf0 (noop);
returns d0=lib.

## XpksPackChunk (a0 = XpkSubParams)

Reads xsp_InBuf/InLen/OutBuf/OutBufLen; writes xsp_OutLen (+0x10).
Workspace cached at xsp+0x34 (Sub[0]): lazily allocs
ctx 84B (MEMF_CLEAR|MEMF_PUBLIC) + tab1 0x20000 + tab2 0x10000
(plain MEMF, then memset by the caller-visible clear loop at 0x1f4).
Sub[0] != 0 -> reuses ctx and re-zeroes both tables (no new allocs).

ctx init: [0]=InBuf [4]=OutBuf [20]=InLen.w [22]=OutBufLen-4.w, then
pack core at 0x52e.  Return: 0 and OutLen on success;
-17 (0xffffffef) when pack returns <0 or OutLen > InLen (expansion);
-7 (0xfffffff9) on AllocMem failure (partial allocs freed via 0x18c).
OutLen is written with the raw core result *before* the range check,
so failures leave 0xffffffff or the oversized length in xsp+16.

## XpksUnpackChunk (a0 = XpkSubParams)

Reads xsp_InBuf/InLen (packed span) and xsp_OutBuf; the expected
output size must be preloaded by the CALLER in xsp+0x10 (OutLen) —
the code uses OutBuf+xsp[16] as the destination end pointer and
never writes OutLen back.  Literals are pulled backwards from the
packed tail (a4@-), matches decoded through the class tables at
code+0x3d4.  Always returns 0; no error detection.

## Internal layout (code offsets)

- 0x1f4  clear tab1 (0x20000B) + tab2 (0x10000B) — ctx in a0
- 0x36c..0x433  offset-class tables (seltab @0x36c, per-class
  {16 base,16 nbits,16 jump-off} triples, copy-count tables)
- 0x434  bit writer: 4 delayed-slot streams
- 0x52e  pack core (hash chains a3=tab1, a6=tab2, window 0x2aa0)
- 0x862  pack ctx init;  0x8ec final flush;  0x950 tail copy +
  0xfb pad alignment + OutLen computation
- 0x992  unpack core (jmp pc@(off,idx) dispatch)
- 0xaec, 0xaf0  noop rts stubs (expunge hook / init tail call)
