---
type: Structure
title: geclass_37.6 layout
---

# File / hunk map

Load file, 2,964 bytes.  Header `HUNK_HEADER` (0x3f3): no resident
names, table size 2, first hunk 0, last hunk 1; sizes `[0x2bb, 0x30]`.

| hunk | tag          | size          | contents |
|------|--------------|---------------|----------|
| 0    | HUNK_CODE    | 0xaec bytes   | RomTag + AUTOINIT table + all code/data/strings |
| 1    | HUNK_BSS     | 0xc0 bytes    | private state block (no body in file) |

RELOC32 records for hunk 0, in original file order (reproduced
verbatim by `source/fixup.py`; the GNU linker emits them sorted so
fixup rewrites the group/offset order):

- target hunk 0, 16 offsets (descending, nonstandard):
  `8a ba be c2 c6 ca ce b2 98 86 82 1a 16 12 a 6`
- target hunk 1, 7 offsets (ascending):
  `de e4 134 1d2 6b2 6d2 74a`
- hunk 1: no relocations.

# Code hunk layout (offsets from hunk start)

| off     | what |
|---------|------|
| 0x00    | entry stub: `moveq #-1,d0; rts` |
| 0x04    | Resident (RomTag): MatchWord 0x4afc, flags 0x80 AUTOINIT, ver 37, type 9 NT_LIBRARY, pri 0 |
| 0x1e    | `geclass.library\0` (+16 pad) |
| 0x3e    | `GEClass 37.6 (16 Dec 1994)\r\n\0` (+35 pad) |
| 0x7e    | InitTable: dataSize 0x22 (plain `Library`), functab 0xba, datatab 0x8e, init fn 0xd8 |
| 0x8e    | InitStruct datatab (16-bit-offset commands): ln_Type=9, ln_Name, lib_Flags=6, lib_Version=37, lib_Revision=6, ln_IdString |
| 0xba    | functab: 6 absolute `.long` vectors + 0xffffffff endmark |
| 0xd6    | rt_EndSkip end / pad |
| 0xd8    | `_init` — AUTOINIT init function (see below) |
| 0x130   | once-latched dependency cleanup (`bset #0,bss+0x88`) |
| 0x14c   | assert-crash: literal 0x4afc ILLEGAL |
| 0x150   | `_check` — assert(flag,msg): crashes if flag==0 |
| 0x164   | `_openlib` — OpenLibrary wrapper; NULL -> clear bss+0x10, jump bss+0x84 (init longjmp) |
| 0x180   | `_closelib` — CloseLibrary if non-NULL |
| 0x194/0x196 | dead ctor/dtor stubs |
| 0x198   | vector -6  Open |
| 0x1a8   | vector -12 Close |
| 0x1bc   | vector -18 Expunge |
| 0x204   | vector -24 (moveq #0; rts) |
| 0x208 / 0x242 | scale helpers: `arg * w|-2|-4 / 20|14` with sign fixup (rtd #6) |
| 0x27c   | dispatcher body `f(msg,obj,cl)` — switch on MethodID |
| 0x28e   | OM_NEW handler — super, then default im_Width=20/im_Height=14 if IA_Width/IA_Height tags absent |
| 0x2fe   | IM_DRAW handler — super, then SetDrMd(1), SetAPen, Move, PolyDraw of 13-pt border |
| 0x46a   | default handler — pass to superclass dispatcher |
| 0x470   | jump table: index -1 ->0x46a; [0x101]->0x28e; [0x102..0x201]->0x46a; [0x202]->0x2fe |
| 0x686   | switch dispatch + shared epilogue (rtd #12) |
| 0x6ac   | dispatcher hook entry `h_Entry(a0=cl,a1=msg,a2=obj)` |
| 0x6c8   | classID name resolver + NewObjectA tail |
| 0x738   | vector -30 MakeNewObject |
| 0x744   | vector -36 DisposeObject passthrough |
| 0x764   | open-all deps (counter bss+0x8c): exec33, intuition33, graphics33, utility36, MakeClass, OpenLibrary(iff), iff -30 |
| 0x7fc   | close-all deps: FreeClass, CloseLibrary(iff), then per-lib counters |
| 0x858   | border coordinate table: 13 signed-word (x,y) pairs |
| 0x88e   | `getfileiclass\0` |
| 0x89c   | `textfieldgclass\0` |
| 0x8ac   | `frameiclass\0` |
| 0x8b8   | `GEClass: Make GetFileImageClass failed !\0` |
| 0x8e2   | `iff.library\0` |
| 0x8fc   | exec.library open/close pair (cnt bss+0x9c, base +0xa0, ver +0x9e); name at 0x930 |
| 0x940   | CallHook trampoline (hook,arg1,arg2 -> h_Entry) |
| 0x968   | DoSuperMethod wrapper (msg,obj,cl -> CallHook cl_Super) |
| 0x998   | module counter pair (ctor/dtor stubs) |
| 0x9bc   | utility.library open/close (v36); name at 0x9f0 |
| 0xa00   | graphics.library open/close (v33); name at 0xa34 |
| 0xa48   | intuition.library open/close (v33); name at 0xa7c |
| 0xa90   | bounded dual-limit strcmp, callee pops 16 |
| 0xae8/0xaea | ctor/dtor stubs |

# BSS block (hunk 1) map

| off   | field |
|-------|-------|
| 0x0c  | seglist (returned by Expunge) |
| 0x10  | library base (cleared on dep-open failure -> init returns 0) |
| 0x72  | exec `lib_Version` copy |
| 0x80  | saved SP for the init-failure longjmp |
| 0x84  | failure continuation pointer (-> 0x120) |
| 0x88  | cleanup-once latch (bit 0) |
| 0x8c  | dependency open/close counter |
| 0x90  | GetFileImageClass — MakeClass("frameiclass" subclass, classID 0) |
| 0x94  | TextFieldClass — result of `iff.library` -30, 0 if iff absent |
| 0x98  | iff.library base |
| 0x9c/0x9e/0xa0 | exec.library cnt / ver / base |
| 0xa4  | module counter |
| 0xa8/0xaa/0xac | utility.library cnt / ver / base |
| 0xb0/0xb2/0xb4 | graphics.library cnt / ver / base |
| 0xb8/0xba/0xbc | intuition.library cnt / ver / base |

# IM_DRAW coordinate table (0x858)

13 signed (x,y) word pairs, scaled by `scale_x = x*width/20`,
`scale_y = y*height/14` (width/height taken from the object's
im_Width/im_Height at +4/+6), then offset by imp_Offset:

```
(0,-6) (1,-6) (1,0) (11,0) (11,-6) (9,-8) (6,-8)
(4,-6) (2,-6) (2,-5) (5,-5) (6,-4) (10,-4)
```

A 3D-ish corner/frame border; drawn into a 26-word stack array
(linkw #-0x3a) and passed to `PolyDraw(rp, 13, pts)`.
