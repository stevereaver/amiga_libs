---
file: vectors
---
# Vectors (12 abs-long @h0+0xae, LVO -6..-72)

-6 Open +0x110 — opencnt@lib+0x20; first open pushes a6,
SysBase<-h1+4, OpenLibrary(0) x5: dos->h1+0, gfx->h1+8,
toolkit->h1+0xc, dgiff->h1+0x10, dgaudio->h1+0x14; any
failure closes opened deps (helper +0x19c) and returns 0;
clears DELEXP (bclr #3,lib+0xe). | -12 Close +0x216 —
opencnt--, at 0 closes deps back-to-front (+0x14..+0), then
expunges if DELEXP. | -18 Expunge +0x236 — opencnt>0: set
DELEXP, ret 0; else d0=seglist@lib+0x22, SysBase<-h1+4,
exec Remove + FreeMem(lib-negsz, negsz+possz). |
-24 +0x276 moveq#0/rts. |
-30 +0x27c tag-arg play — d0=taglist, a0=stream ctx,
a1=buf; tags {1:x2, 0x10002:ptr+len x2, 0x20001, 0x30001,
0x40001, 0x50001, 0x60001, 0x70000(mode, dead cmp),
0x80000}, -1 term; 12B defaults from h1+0x20; tk-120,
AllocMem 0x6000 x2, dgiff-42 read, FreeMem x2 on bail. |
-36 +0x5e4 8SVX prepare — STACK args (gcc ABI):
arg1=bigctx(sp+4), arg2=chunk node(sp+8); node+0x22 must
be 'BODY'; calls -42 for 'VHDR', fills ctx+0x1c..0x26,
tk-42 link, tk-120 8B id compare, FreeMem(node,42),
AllocMem(42+cksize), dgiff-66/-114, tk-36, returns 1. |
-42 +0x90a chunk find — d0=chunkID, a0=list owner
(a0@(8)=head); walks next@0 chain, recurses sublist@0x10,
compares id@0x22; returns node or 0. |
-48 +0x954 feed mono chunk — a0=ctx {0:chan,4:chan2(-1),
8:dst1,0xc:dst2,0x10:size,0x14:src,0x18:remain,0x1c:chunk,
0x20:period}; chunk /= (SysBase+0x212)>>1; tk-120 copy,
dgaudio-66 submit, gfx-270 WaitTOF, dgaudio-60/-96. |
-54 +0xc14 feed stereo pair — same ctx; halves
size+remain, two tk-120 copies + two dgaudio-66/-60/-96. |
-60 +0xef8 play/pump — a0=ctx; tk-228 registers h1+0x18
tick stub (a3=handle), then loop: tk-120, dgiff-66 fill,
dgaudio-66 submit, -60/-96 drain, gfx-270, dgiff-72 seek
(-a5@0x18), user callback jsr a5@(0x28) result gates stop;
tk-234 unregisters handle. |
-66 +0x1328 fib-delta unpack — d0=nibble count, a0=src,
d1=init, a1=dst; 4-bit codes through h1+0x2c table, returns
last sample (d7). |
-72 +0x1382 fib-delta packed — a0=src (byte1=init,
data@+2), d0=len; bsr -66.

Helper +0x13a4: gcc-style signed 32/32 division (divuw
loops), used for channel-count and VHDR rate scaling.
