---
type: Log
title: xpkRLEN 1.1 reverse-engineering log
---

# Reverse-engineering log — xpkRLEN.library V1.0/1.1

Source artifact: `binary/xpkrlen_1.1.library`
1384 bytes · sha256 `62c8e5a968b50ce256892b1c102d0ae2c0adbedf4be4f22796fa84e48e28cb5e`

## Phase 1 — structure

Two hunks: CODE (0xea longs) + DATA (0x45=276B).  SAS/C
build — the RomTag's RT_INIT points at INIT in the DATA
hunk.  InitTable dataSize 0x13a = 314 = base(0x22) + seglist
+ 20B gap + 0x100 template.  FUNCTABLE is a long-address
table (no word offsets), 10 vectors + ffff ffff guards.

## Phase 2 — init machinery

INITFUNCTION (SAS/C-style): writes the base fields manually
(ln_Type=9, name, flags=6, ver=1, rev=0, idstr, seglist),
then copies the 256-byte template SECSTRT_1 -> base+58 and
runs a 4-entry fixup pass: for each offset in the list at
data+0x100 ({0xe2,0xb6,0xb2,0xae}), `*(base+58+off) +=
base+58` — turning template-relative descriptor pointers
absolute.  LIBFUNC_0 returns base+58+166 = base+224 -> the
XpkInfo inside the copied block.

## Phase 3 — codec

Packer (LIBFUNC_1): scan cursor + literal cursor.  Each iter
checks 3-in-a-row (`in[c]==in[c+1]==in[c+2]`); pending
literals = cur-lit.  On run-detect / lit==127 / input-end it
flushes `<lit count><bytes>`.  Terminator `0` at input end.
Runs extend while `in[cur+rl]==in[cur+rl-1]` (contiguous
equal bytes), capped at 127, emitted as `<-len><byte>`.
Bound check reserves `lit+4` bytes of output headroom.

Decoder (LIBFUNC_4): `count>0` copy literals, `<0`
replicate next byte, `0` stop.  No bounds anywhere.

## Phase 4 — quirks

- 3-in-a-row lookahead reads in[cur+1],in[cur+2] OOB at the
  tail (values only gate the run branch)
- run emit has NO output bound (literal path does, loosely)
- decoder never bounds output and never stores xsp_OutLen
- PackFree/Reset/UnpackFree stubs return d0-untouched

## Phase 5 — host validation

19701 round-trips, 0 errors, 299 `-17` rejects.  A first-cut
run-extension bug (incremented before checking, merging
consecutive runs) was caught by a 32000-byte case and fixed
to check the current position before incrementing.
