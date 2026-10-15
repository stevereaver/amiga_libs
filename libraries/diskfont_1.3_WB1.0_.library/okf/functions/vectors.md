---
type: Functions
title: diskfont 1.3 (WB1.0) vector map
---

# Vector map (functab h0+0x158, 6 absolute longs + 0xffffffff)

-6  Open      h0+0x21e — bclr #7,lib_Flags(+0xe) (clears DELEXP);
              addq #1,lib+0x26 (PRIVATE opencnt word, not
              lib_OpenCnt@+0x20); returns a6.
-12 Close     h0+0x22c — subq #1,lib+0x26; if opencnt hits 0 and
              DELEXP set: jmp a6@(-18) (self-expunge); else ret 0.
-18 Expunge   h0+0x174 — first walks the private font list at
              lib+0x2a: nodes with word@node+0x54 (accessors) <= 0
              are unlinked and UnLoadSeg(node+0x12) via DOSBase;
              lib+0x28 fontcount decremented. Then refuses (bset
              #7 DELEXP, ret 0) if opencnt(lib+0x26)!=0 OR
              fontcount(lib+0x28)>0. Else CloseLibrary(-414) on
              GfxBase(hunk2+0xc) and DOSBase(hunk2+8),
              FreeMem(-210) lib-negsize for 92B, unlink lib node,
              return d0 = lib+0x22 (seglist stored by rt_Init).
-24 Reserved  h0+0x21c — bare rts (returns stale d0).
-30 OpenDiskFont  h1+0x12 — thunk: push a0, jsr h5+0xe0,
              addq #4,sp.  a0 = TextAttr.
-36 AvailFonts    h1+0x00 — thunk: push d0/d1/a0, jsr h3+0.
              a0=AvailFontsHeader buf, d0=bufBytes, d1=flags
              (1=AFF_MEMORY resident-list pass, 2=AFF_DISK
              'FONTS:' scan).

## Implementation map

- h0+0x4c  rt_Init: moveml a0/a2 (saves CALLER regs; incoming a0
           is the seglist), lea functab@h0+0x158->a0, datatab
           @h0+0x130->a1, initfn@h0+0x7a->a2, d0=0x38, jsr
           a6@(-84) MakeLibrary; on success movel a0,lib+0x22,
           jsr a6@(-396) AddLibrary; rts (d0 = AddLibrary ret).
- h0+0x7a  libInit (called by MakeLibrary, d0=lib): hunk2+4=
           ExecBase, hunk2+0=libself, a6=lib; OldOpenLibrary
           'dos.library'->hunk2+8, 'graphics.library'->hunk2+0xc;
           NewList lib+0x2a; ret lib. Failure: CloseLibrary +
           FreeMem(lib-negsize, neg+pos), ret 0.
- h3+0     AvailFonts impl (link a6,#-272; C stack args):
           flag&1 -> walk font list via GfxBase+0x8c chain,
           emitting 10-byte afh entries {type=1, nameptr, ysize,
           style, flags}; flag&2 -> AllocMem(260) fib,
           Lock("FONTS:",-2), CurrentDir, Examine, ExNext loop:
           skip dirs, strrchr '.' + strcmp ".font" via h7,
           Open/Read 4B header (must be 0x0f00) + Nx260B
           FontContents -> emit type=2 entries; cleanup frees fib,
           restores dir, unlocks.
- h5+0     weigh helper: scores candidate FontContents (a0: +4
           ysize +6 style +7 flags) vs request (a1: +256 ysize,
           +258 style, +259 flags) using penalty tables in hunk6
           (+8/+0x28/+0x48/+0x68, 8 longs each); returns score in
           d0 (-32767 sentinel when request ysize==0? reads
           a1@(0x100) flag).
- h5+0xe0  OpenDiskFont impl (link a6,#-286): copy TextAttr,
           basename via h7+0xb6, gfx OpenFont(-72) probe;
           miss -> Lock("FONTS:",-2) [h6+0], CurrentDir,
           Lock(basename), Open(basename,0x3ed), Read hdr +
           N*260 entries into AllocMem, weigh each (jsr %pc@(h5+0)
           twice), LoadSeg(fc_FileName) via dos thunk, check
           word@seg+8+14 == 0x0f80, strcpy basename to node+22,
           ori.b #2,node+0x4d, Forbid, AddFont(-480) node+0x36,
           node+0x54 accessors++, AddTail(lib+0x2a, node),
           lib+0x28++, Permit; cleanup closes file/locks, frees
           entry buf.  Returns node+0x36 (embedded TextFont).
- h7       strcpy@0 (a1<-a0), strcat@0x10, strlen@0x30,
           strcmp@0x40 (-1/0/1), strchr@0x68, strrchr@0x84,
           path-tail@0xb6 (after last '/' or ':').
- h10      dos thunks (a6<-hunk2+8 DOSBase): +0 Open-30,
           +0x1c Close-36, +0x30 Read-42, +0x4c Lock-84,
           +0x68 UnLock-90, +0x7c Examine-102, +0x98 ExNext-108,
           +0xb4 CurrentDir-126, +0xc8 LoadSeg-150, +0xdc
           UnLoadSeg-156.  Stray '0000' pad words at 0x1a,0x4a,
           0x66,0x96,0xb2.
- h11      exec thunks (a6<-hunk2+4 ExecBase): +0 Forbid-132,
           +0x10 Permit-138, +0x20 AllocMem-198, +0x38 FreeMem-210
           (pad at 0x36), +0x50 AddTail-246.
- h12      gfx thunks (a6<-hunk2+0xc GfxBase): +0 OpenFont-72,
           +0x14 CloseFont-78, +0x28 AddFont-480.

## External LVOs observed

exec: -84 MakeLibrary, -396 AddLibrary, -408 OldOpenLibrary,
-414 CloseLibrary, -210 FreeMem, -132 Forbid, -138 Permit,
-198 AllocMem, -246 AddTail, -18 self-expunge.
dos: -30 Open, -36 Close, -42 Read, -84 Lock, -90 UnLock,
-102 Examine, -108 ExNext, -126 CurrentDir, -150 LoadSeg,
-156 UnLoadSeg.
graphics: -72 OpenFont, -78 CloseFont, -480 AddFont.
