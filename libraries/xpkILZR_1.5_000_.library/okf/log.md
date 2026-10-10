---
type: Log
title: xpkILZR 1.5 reverse-engineering log
---

# Reverse-engineering log — xpkILZR.library V1.5

Source artifact: `binary/xpkILZR_1.5(000).library`
1384 bytes · sha256 `e5da00e5efb71a483e62a9e463b7e3166e7803a5e56255650a222cf3d4ba583e`

## Phase 1 — structure

Single CODE hunk, AUTOINIT.  `moveq #0,d0;rts` entry stub
doubles as the null vector (two functab slots point back
to it with a negative word offset).  InitTable dataSize
0x26 — base carries only the seglist.  datatab: ver 1
rev 5, idstr `$VER: xpkILZR V1.5 (1 Oct 2013) by Jose Reanu`.
functab = `ffff` + 10 word offsets + `ffff`.

## Phase 2 — framework

LibInit stashes the seglist at base+0x22.  Open/Close/
Expunge are textbook; Expunge does Remove+FreeMem.
ExtFunc (-24) and UnpackFree (-60) alias the entry stub.

## Phase 3 — sublib machinery

XpksPackFree frees `xsp_Sub[0]-4` (size-prefixed block)
but does NOT clear xsp_Sub[0] — dangling pointer; a later
pack reuses freed memory (use-after-free, latent).

XpksPackReset clears the 64KB head[] table downward from
workmem+0x10004 with a movem fill (315*208+16 = 65536 B),
no-op when xsp_Sub[0]==0.  The chain table is NOT cleared
(stale links are harmless — each insert overwrites them).

XpksPackChunk lazily AllocMem's 0x18004 (size prefix + 256KB
scratch): head[0x8000] words at +0, chain[0x8000]?? — the
chain is only 0x4000 words (16KB) because positions are
capped by MaxPkInChunk=0x4000; see findings.

## Phase 4 — codec

Encoder: rolling 15-bit hash `h=(h<<5 ^ b)&0x7fff`,
hash-chain candidates via `chain[pos]=head[h];head[h]=pos`.
Deferred insertion — each loop head inserts the span the
last item consumed plus the new position (dbf-through-the-
dbf semantics, exactly `plen` positions).  Position 0 reads
as "empty" so it can never be a match source.  Match scan:
precheck `in[cur+best]==in[cand+best]`, then a cmpm compare
capped at 18; best-so-far wins; early-accept at 18.
len<3 -> literal.  Emits MSB-first bits; write-then-check
against out+inlen gives -17.  Tail (rem<3) emits literals
without hashing.  OutLen stored; flush pads with 0-bits.

Decoder: outlen word, -14 when it exceeds the caller-preset
xsp_OutLen; bit reservoir refilled byte-wise; width field
grows as output crosses 2^w; match copies `len=d0+3` bytes
from `out[pos]` (ABSOLUTE index); loop while rem>0 — a
terminal oversized match overwrites past outlen (no bound).

## Phase 5 — host validation

3647 random round-trips pass, 0 failures, 4353 `-17`
rejects (incompressible data expands -> correct reject).
The 18-cmpm maximum-match walk and the deferred-insert
cursor arithmetic were validated against a Python model
of the register machine (200/200) before writing C.
