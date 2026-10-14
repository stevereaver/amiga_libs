---
type: Function
title: xpkNUKE_1.7 vector map
timestamp: 2026-10-14T00:00:00Z
---

# Vectors (offsets relative to hunk-0 start)

| LVO  | offset | function |
|------|--------|----------|
|  -6  | 0x09e  | LibOpen — opencnt++, forbid-flag, returns lib |
| -12  | 0x0ac  | LibClose — opencnt--; deferred expunge or null |
| -18  | 0x0c0  | LibExpunge — opencnt>0 sets LIBF_DELEXP ret 0 |
| -24  | 0x104  | LibNull (`moveq #0,d0; rts`, ends at 0x106) |
| -30  | 0x848  | XpksPackerInfo — returns &XpkInfo (data hunk +0x2a) |
| -36  | 0x952  | XpksPackChunk |
| -42  | 0x8b6  | XpksPackFree |
| -48  | 0x134  | LibNull (`moveq #0,d0; rts`) — shared with InitFn |
| -54  | 0x9c6  | XpksUnpackChunk |
| -60  | 0x134  | LibNull |

The functab at code+0x2e is the **absolute-address** flavour: ten
longwords of code offsets + a `0xffffffff` terminator (relocation
makes them absolute).  This is the 1.16-era skeleton, not the
word-offset table of 1.8/1.9.

InitTable at code+0x1e: `datasz=0x22, functab=0x2e, datatab=0x5a,
initfn=0x7e`.  The datatab (InitStruct commands) at code+0x5a writes
type=9, name->code+0x108, flags=6, version=1, revision=7,
idstr->code+0x118 into the fresh lib base.

LibInit (0x7e) stores the a0 seglist into a **code-segment slot at
code+0x7a** (`movel a0,0x7a`), then `bsr`s the PostInit stub at
0x134 (a shared `moveq #0,d0;rts` — it always "fails" the
nonzero-test path and the init returns the lib base).  Expunge
reads the seglist back pc-relative (`movel %pc@(0x7a),d2`).

rt_EndSkip = 0x106, which is the `rts` half of the -24 stub —
the RomTag scan region deliberately ends inside that stub.

## XpksPackChunk (a0=xsp) — wrapper at 0x952

- `xsp_Sub[0]` (xsp+52) caches the workmem; NULL → calls the
  allocator at 0x902.  Alloc failure path returns **-7**.
- Allocator 0x902 does three AllocMem calls: 92-byte header with
  MEMF_CLEAR (`d1 = 1<<16`), then tab1 0x20000 and tab2 0x10000 with
  flags=0 (NOT cleared by exec).  On any failure it calls
  XpksPackFree and returns NULL.
- Marshals xsp fields into the header, then memsets **both** tables
  unconditionally every call (backward byte clear at 0x9e8:
  `subql #1,d1 / moveb d0,a1@(0,d1:l)` — writes 0x20000 then
  0x10000 zero bytes).
- Calls pack_core at 0x2fa (`bsrw`), stores its raw return at
  `xsp+16` (so -1 is stored as-is), returns -17 unless
  `0 <= rc < xsp_InLen` → 0.

## XpksPackFree (a0=xsp) — 0x8b6

Walks `xsp->xsp_Sub[0]` header: FreeMem(tab1, 0x20000) if non-NULL,
FreeMem(tab2, 0x10000) if non-NULL, FreeMem(w, 92), then
`clrl a5@(52)`.  Returns 0 when nothing cached; when a workspace
existed it returns whatever the last FreeMem left in d0 — the final
jsr was `FreeMem(w,92)` so the leftover is **0x5c** (sic; the
routine passes d0 straight through).

## XpksUnpackChunk (a0=xsp) — 0x9c6

Wrapper marshals: a4 = InBuf+InLen (literal tail end), a5 = InBuf
(stream read head, forward), a0 = OutBuf, a2 = OutBuf+OutLen
(xsp+16); bsr to the decoder at 0x73c, which returns the final out
pointer in d0 — the wrapper discards it and always returns 0.

## XpksPackerInfo — 0x848

`lea 0x2a,a0 / movel a0,d0` — the 0x2a long is relocated to hunk 1,
so the return is `datahunk+0x2a` = &XpkInfo.  Everything behind the
descriptor lives in the data hunk (mode entry at data+0, strings
point back into the code hunk at 0x852..0x8b5).

## Internal subroutines (code offsets)

| addr  | role |
|-------|------|
| 0x134 | shared null stub (moveq#0;d0/rts): InitFn + -48/-60 vecs |
| 0x200 | flush_lit: emit '0' flag, copy d7+1 lits backward, count code |
| 0x2fa | pack_core: the LZ77 cruncher (a4 = &Work) |
| 0x60e | pack_init: zero stream counters, seed ptr1-4 = &scratch |
| 0x696 | pack_finish: force trailing literals + drain accumulators |
| 0x6fa | pack_tail: append literal block, 0xfb-pad to long align |
| 0x73c | unpack_core: the decoder |
| 0x902 | pack_alloc: three AllocMems + cleanup on failure |
| 0x9e8 | backward memset for tab1/tab2 |
