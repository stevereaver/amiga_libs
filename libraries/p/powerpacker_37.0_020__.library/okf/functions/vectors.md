---
file: vectors
---
# Vectors (23 word-offset @h0+0x1d4, offsets rel. to table)

-6 Open +0x12c | -12 Close +0x13c | -18 Expunge +0x150 |
-24 +0x1d0 | -30 +0x95c | -36 +0x210 | -42 +0xc60 |
-48 +0x5f0 | -54 +0x600 | -60 +0x888 | -66 +0x898 |
-72 +0x8a4 | -78 +0x662 | -84 +0x61c | -90 +0x618 |
-96 +0xc74 | -102 +0xd98 | -108 +0xdc8 | -114 +0x830 |
-120 +0x87c | -126 +0xbf0 | -132 +0x928 | -138 +0xde8.

initfn @h0+0xbc: libbase->h0+0x16a4, seglist(a0)->lib+0x24;
OldOpenLibrary(-408) intuition->h0+0x16a8, graphics->+0x16ac,
dos->+0x16b0; writes 12B descriptor @h0+0x168c
(0x80000003/0x2/0x80000021); Forbid(-132), SetFunction(-420)
patches exec FreeMem(-210) -> h0+0x940 hook, old vec->h0+0x16a0,
Permit(-138), returns libbase.

Lifecycle: Open addq opencnt + bclr DELEXP; Close subq
opencnt, falls into Expunge when 0+DELEXP; Expunge checks
exec FreeMem jump-target (a6@-208) still == h0+0x940, then
SetFunction-restores old vec, Permit, Remove+FreeMem seglist.

FreeMem hook @0x940: if a1@(0)=='PPMM' (alloc guard tag)
then a1-=8,d0+=8, jmp old-vec — strips the lib's own 8B
alloc headers.

User vectors drive the PP crunch/decrunch core (020+ paths,
huge deterministic buffer walks — 9.35M invalids under the
oracle). Traced: -30 dos Lock(-30) x2 file probe; -96 allocs
crunch ctx (608/16388/1028B); -102 FreeMem teardown; -60/-66/
-72/-84/-120 lazy OldOpenLibrary("reqtools.library") + req
LVOs (-84/-72/-78/-84/-90) then CloseLibrary — error
requesters ("You need reqtools.library", "encrypted file",
"incorrect password", "Please verify"); -114 dos -48; -108
exec -630; -78/-90 AllocMem(8)+exec -624. -24/-42/-48 are
moveq#0/rts stubs (oracle: 0 / -54 returns 0xffff).
