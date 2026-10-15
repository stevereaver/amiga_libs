# xpkTDCS 1.2 — vector detail

Word-offset functab: 10 signed word offsets relative to the
table base, 0xffff-terminated; null vectors point at the shared
`moveq #0/rts` stub.

## Lifecycle (-6/-12/-18/-24)

Standard Froehling xpksub shape: Open (opencnt++, clear
DELEXP), Close (opencnt--; on 0 with DELEXP set → expunge),
Expunge (Remove + FreeMem(base-negsize, neg+pos), return
seglist at base+0x26).  LibInit stores the seglist at +0x26
(NOT +0x22 — dataSize 0x3c leaves +0x22..25 unused) and gates
on `AttnFlags & AFB_68020`; on a plain 68000 it returns 0 and
AUTOINIT fails.

## -30 XpksPackerInfo

`lea (desc,pc),a0; move.l a0,d0; rts` — returns the static
XpkInfo block (structures/layout.md).

## -36 XpksPackChunk

`a0 = XpkSubParams`.  `moveml a0@,d4-d5/a0` loads
InBuf/InLen/OutBuf.  Allocates: CreatePool(0,0x8000,0x1000)
(exec -696), then AllocPooled(0x80000) (exec -708) for the
65536-entry {cap,blk} table, zeroed 0x20000 longs.

Per position: `find` (hash key ((b0<<8)|b1)^b2), then a lazy
chain — lookahead find(cur+1), adopt iff lenL-1 > pending len,
each adopt emits cur's literal through the insert path.
Emit: len < 3 → literal byte; else tier 01/10/11 picked by
(len-3, dist) thresholds; every item shifts 2 bits into the
flag accumulator, flushed to the reserved slot each 16 items.
Fail: -7 alloc, -17 output-overrun (`out >= outend` where
outend = OutBuf + InLen).  Success writes xsp_OutLen.
Details: algorithms/codec.md.

## -54 XpksUnpackChunk

Flag-long decoder.  `d1` pre-set to -1 then `movew` per token —
upper word survives → signed16 distances → backward copies.
Zero flag long = 16 literals via four movel writes (16 bytes,
NOT 64).  11+zero word = terminator, returns 0.  No OutLen
writeback, no input-length check, unbounded copies.

## -42/-48/-60

All three are the shared null stub (`moveq #0/rts`).
XpksPackFree/Reset exist only as LVO slots.
