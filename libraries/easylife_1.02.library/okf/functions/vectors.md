# easylife.library 1.02 — vector map

RomTag @ h0+4, AUTOINIT, ver 1, NT_LIBRARY pri 0.
InitTable @ h0+0x64: dsize=0xfc, functab→0x74, datatab→0xc0,
initfn→0xe0. 18 vectors (-6 .. -108):

| LVO  | off   | role |
|------|-------|------|
| -6   | 0xf0  | Open (opencnt@+32, bclr DELEXP@+14) |
| -12  | 0xfe  | Close (deferred expunge) |
| -18  | 0x118 | Expunge (Remove -252, FreeMem -210) |
| -24  | 0x162 | stub: moveq #0,rts |
| -30  | 0x1d8 | FindArrayElem — search sub-table at pool+d0 for lo-word key d1, return pool + hi-word index |
| -36  | 0x236 | lazy pool init: if lib+240==0 calls hook *(lib+42)() -> pool head |
| -42  | 0x166 | FreeElement — locate chunk on lib+248 chain containing arg, exec Deallocate(-192), lib+244-- |
| -48  | 0x25a | CreateArray — find free slot, Allocate(-186) chunk via _f2b0, store id word; arg1=0x10000 triggers zero-fill |
| -54  | 0x3be | GetElt — desc decode (_f364) + jump table @0x3f4 (12 sel entries -> long/word/byte/bit/str getters) |
| -60  | 0x46a | SetElt — same decode + jump table @0x49a (12 entries -> long/word/byte/bit set/clr/strcpy/lenchk) |
| -66  | 0x548 | CmpElt — GET then memcmp loop, returns -1/0/1 |
| -72  | 0x59c | FreeAll — walk lib+248 chain, FreeMem(-210) each, clear lib+240/244/248 |
| -78  | 0x5f8 | BuildTable — AllocMem sorted/flagged elt array via _f670 collector (bset/bclr #1 on desc+2) |
| -84  | 0x6d0 | FreeBuffer — FreeMem(d0-8, *d0-8) |
| -90  | 0x7b4 | LoadFile — dos Open/Read(-30/-42/-36) via a5@(696)=DosBase; 'ElSt' header, count*4+12 buffer, per-entry records |
| -96  | 0x6e8 | SaveFile — dos Open/Write(-30/-48/-36) via a5@(696); writes 'ElSt' hdr + entries |
| -102 | 0x8e4 | FixPtrs — translate stored indices back to ptrs (d0=base,d1=old-base), recursive _f90e |
| -108 | 0x97a | FreeTable — BuildTable then FreeElement each, FreeBuffer |

Internal helpers: _f236 lazy-init, _f2b0 pool Allocate wrapper,
_f2f6 chunk AllocMem+header init, _f364 spec->linear-index decode
(d0=tableoff,d1=keyptr,d2=boundslist,d3=ndims), _f670/_f90e
recursive element walkers.

Exec LVOs: -186 Allocate, -192 Deallocate, -198 AllocMem,
-210 FreeMem, -252 Remove. DOS LVOs via ctx->dosbase: -30 Open,
-36 Close, -42 Read, -48 Write (MODE_OLDFILE 1005 / NEWFILE 1006).
