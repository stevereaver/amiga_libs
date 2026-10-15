---
file: vectors
---
# Vectors (22 abs-long @h0+0x1ba)

-6 Open +0x114 | -12 Close +0x122 | -18 Expunge +0x134 |
-24 +0x1b6 (->0) | -30 +0x216 (->-2) | -36 +0x23e (->0) |
-42/+0x614, -48/+0x628, -54/+0x638 (->0) |
-60/+0x8b8, -66/+0x8c6, -72/+0x8d0 (OldOpenLibrary probe,
->0) | -78 +0x69a (handle alloc: ~20x AllocMem(8), ->ptr) |
-84 +0x650 (OldOpenLibrary, ->0) | -90 +0x64c (AllocMem +
exec -624, ->ptr|flags) | -96 +0xde2 (big allocs
604/16388/1028 = crunch/decrunch core entry, ->buf) |
-102 +0xdbc (FreeMem cleanup, ->0) | -108 +0xf0a (exec
-630, ->-1) | -114 +0x860 (echoes d0) | -120 +0x8ae
(OldOpenLibrary probe, ->0) | -126 +0xd0c (->0) |
-132 +0x986 (->code ptr).

initfn @h0+0xb8: movem, a1=BSS base (h1 reloc @0xbe),
a5=libbase, seglist->lib+0x24. 3x OldOpenLibrary(-408)
for intuition/graphics/dos — NOTE dep bases stored at
name+4/+8/+0xc, i.e. INTO the dep-name strings (self-
modifying; names clobbered after open). Then Forbid(-132),
SetFunction(-420) patches exec LVO -210 (FreeMem) ->
hook @h0+0xa50 ('PPMM' tagged @0xa52), old vec saved
@h0+0xa4c (abs-store reloc @0x104), Permit(-138), rts.

Deps: dos/intuition/graphics at init; "You need
reqtools.library" nag string implies lazy reqtools dep
for error requesters.
