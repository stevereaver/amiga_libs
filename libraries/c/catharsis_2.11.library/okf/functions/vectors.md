---
file: vectors
---
# Vectors (abs-long functab @h1+0x58, 23 entries, -1 term)

-6  Open    ->h0+0xf2a  addq #1,lib+0x22; flags &= ~8; ret lib
-12 Close   ->h0+0xf38  if cnt>0 dec; if cnt==0 && flag8 -> jmp
                        expunge(h0+0xf84); else ret 0
-18 Expunge ->h0+0xf84  calls sweep h0+0x91c; if d0!=0 or
                        opencnt!=0 -> flags|=8, ret 0 (deferred);
                        else h0+0x10bc CloseLibrary(intui,gfx),
                        Remove(lib), FreeMem(lib-neg, neg+pos),
                        ret seglist (lib+0x24)
-24         ->h0+0x101c moveq #0,d0; rts  (reserved stub)
-30         ->h0+0x0    *relocated-0 slot* — lands on the real
                        function at CODE+0 (link a5,#-6, stack arg
                        a5@(8)->a2, loops GfxBase@-318 calls)
-36  ->h0+0x53c   -42  ->h0+0x554  (AllocMem 52 + CopyMem(-624)
        + AllocMem 296 + gfx allocs — builds a table ctx)
-48  ->h0+0x784   -54  ->h0+0x79c  (Obtain/ReleaseSemaphore +
        same ctx-build path as -42)
-60  ->h0+0x8c6   (sem-bracketed)
-66  ->h0+0x8ea   -72  ->h0+0x8fa
-78  ->h0+0x9e0   -84  ->h0+0xa90  (return 0xff under oracle)
-90  ->h0+0xab4   -96  ->h0+0xaee  -102 ->h0+0xb0e  (ret 0)
-108 ->h0+0xb4e  (ret echoes d0 arg)
-114 ->h0+0xb60   -120 ->h0+0xd3e  (mask/shuffle of args)
-126 ->h0+0xd74   -132 ->h0+0xe30  (call GfxBase@-60)
-138 ->h0+0x91c   table sweep: ObtainSemaphore(lib+0x838); for
        i<256: if slot pair [lib+0x38+i*4 / lib+0x438+i*4] set and
        node+30 <= 0 -> FreeMem(node+34, node+20*node+38) +
        FreeMem(node,52), clear slots; else count it (d2++);
        ReleaseSemaphore; ret d2. Shared by Expunge.

initfn @h0+0xe8c (AUTOINIT): if lib+0x2c==exec -> ret lib (re-
entry guard); fills node (type 9, name->h1+0x28, flags 6, ver 2,
rev 11, id->h1+0x3c), lib+0x24=seglist, lib+0x2c=exec; jsr
h0+0x1020: NewList(lib+0x838), OpenLibrary("graphics.library",
33)->lib+0x30/BSS+4, OpenLibrary("intuition.library",33)
->lib+0x34/BSS+8; on intui fail CloseLibrary(gfx). Returns lib
or 0. Params d0=libbase, a0=seglist, a6=execbase.
