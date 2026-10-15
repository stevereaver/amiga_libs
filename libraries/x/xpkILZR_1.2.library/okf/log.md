---
type: Log
title: xpkILZR 1.2 reverse-engineering log
---

# Reverse-engineering log — xpkILZR_1.2.library

Source artifact: `binary/xpkILZR_1.2.library`
2088 bytes · single code hunk · 14 HUNK_RELOC32 entries

## Phase 1 — structure

HUNK header → RomTag at code+4 (RTF_AUTOINIT, ver 1,
NT_LIBRARY) → InitTable at code+0x1e: dataSize 0x114,
word-offset functab, datatab NULL, initfunc code+0x1b2.
Functab decoded: -24 is a BACKWARD offset (0xffd2) onto
the entry stub; -60 → a bare `rts` at code+0x660.

## Phase 2 — lifecycle

LibInit is manual (no InitStruct data): fills node/flags/
version/idstring, stores seglist, then copies 192 bytes
code+0xea → base+0x3c and stashes +0x2e=0, +0x32=self,
+0x36=0x3c.  LibOpen allocates 0x150 bytes and copies
[base-0x3c, base+0xfc) — every open gets a PRIVATE COPY of
the library (plus a dead offset-fixup walk that never runs
because +0x2e is always 0).  CacheClearU after the copy.
Close frees the copy and decrements the master's count;
Expunge resolves the master via +0x32.

## Phase 3 — descriptor decode

Raw block at file 0x10a: pad + "$VER: xpkIZLR.library 1.2
(Feb 19 1994) Jose Renau" (typo'd IZLR) + mode record at
block+0x38 (upto 100, flags 1, speeds 200/300, ratio 655,
"Fast") + XpkInfo at block+0x62 (versions 1/0/0/0,
flags 0x8009, MaxPkIn/DefPkIn 0x4000, msgs, DefMode 50,
ModeDesc = 0x38 BLOCK-relative — the Open fixup that would
rebase it is dead).  Block tail long at +0xbc = 0x1000 =
the pool allocator's minsize field (base+0xf8).

## Phase 4 — codec

Register-machine pack: a2 cursor, a5 out flag-byte cursor,
a6 chain table, runcap tail budget (initial min(17,InLen),
decremented per insert once the end-scan trips; lands
exactly at consumed = InLen, doubling as the match-length
clamp — emitted len ≤ 17 mid-stream).  Hash
`(in[p]<<10 ^ in[p+1]<<5 ^ in[p+2]) & 0x7fff`; head[]
cleared every pack, chain[] NEVER cleared.  Finder:
candidate walk with monotonic check, precheck byte, cmpm
then groups-of-8 scan to cur+18, fail budget 18.

Decoder: declared u16 vs +0x0c → -10, then OVERWRITES
+0x0c; flag/literal/match as MSB-first bits; width grows
past base+2^w; match copies from out+ABS(pos); no
production bound; 4-byte stream grabs over-read.

## Phase 5 — reconstruction & host validation

C transliteration with asm skeleton (manual LibInit,
descblock in .s, bare-rts UnpackFree).  m68k HUNK build
via two-pass word-offset functab; relocs structurally
equivalent (14→17; extra = LibInit's absolute string refs).
Host round-trips: text/zeros/rep/abab/ramp/rand/32KB +
boundary lengths 1,2,15..25 all pass; -10 verified on a
short OutBufLen; -17 on pack overflow.  Decoder shown to
also decode 1.5-family streams (same format).
