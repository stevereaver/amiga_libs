---
file: vectors
---
# Vectors (23 abs-long @h0+0x1ba, -1 term @h0+0x216)

-6 Open +0x114 | -12 Close +0x122 | -18 Expunge +0x134 |
-24 +0x1b6 (->0) | -30 +0x21a (->-2) | -36 +0x242 (->0) |
-42/+0x618, -48/+0x62c, -54/+0x63c (->0) |
-60/+0x8c0, -66/+0x8ce, -72/+0x8d8 (OldOpenLibrary probe,
->0) | -78 +0x69e (handle alloc: ~20x AllocMem(8), ->ptr) |
-84 +0x654 (OldOpenLibrary, ->0) | -90 +0x650 (AllocMem +
exec -624, ->ptr|flags) | -96 +0xdc2 (big allocs
608/16388/1028 = crunch/decrunch core entry, ->buf) |
-102 +0xda0 (FreeMem cleanup, ->0) | -108 +0xec6 (exec
-630, ->-1) | -114 +0x868 (echoes d0) | -120 +0x8b6
(OldOpenLibrary probe, ->0) | -126 +0xd00 (->0) |
-132 +0x98e (->code ptr) | -138 +0xee8 (NEW vs 35.344:
stores a1/d0/a1+d0 into ctx a0+0x30/0x34/0x38, a2->a0+0x58,
tail-calls core, ->status 0x245 under oracle).

initfn @h0+0xb8: movem, a4=BSS base (h1 reloc @0xbe),
libbase->BSS[0] + a5, seglist(a0)->lib+0x24. 3x
OldOpenLibrary(-408) for intuition/graphics/dos — NOTE dep
bases stored at name+4/+8/+0xc, i.e. INTO the dep-name
strings (self-modifying; names clobbered after open). Then
Forbid(-132), a1=execbase, a0=hook@h0+0xa58, SetFunction
(-420) patches exec LVO -210 (FreeMem) -> hook ('PPMM' tag
compare @0xa5c against a1-8 alloc guard), old vec saved
@h0+0xa54 (abs-store reloc @0x104), Permit(-138), rts.

Deps: dos/intuition/graphics at init; "You need
reqtools.library" nag string implies lazy reqtools dep
for error requesters.
