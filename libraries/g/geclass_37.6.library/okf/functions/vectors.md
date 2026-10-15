---
type: Function
title: geclass_37.6 vector map
---

# Vectors (offsets relative to hunk-0 start)

Functab at code+0xba, absolute `.long` entries, -1 terminator:

| LVO  | offset | function |
|------|--------|----------|
|  -6  | 0x198  | LibOpen — `lib_OpenCnt(+0x20)++`, clears LIBF_DELEXP (bit 3 of `lib_Flags` +0xe), returns lib base in d0 |
| -12  | 0x1a8  | LibClose — `OpenCnt--`; if it reaches 0 and DELEXP is set, tail-calls expunge; returns d0=0 otherwise |
| -18  | 0x1bc  | LibExpunge — OpenCnt>0: set DELEXP, return 0 (deferred). Else: `Remove(lib)`, once-latched dep cleanup, `FreeMem(lib-NegSize, NegSize+PosSize)`, returns seglist |
| -24  | 0x204  | LibNull — `moveq #0,d0; rts` |
| -30  | 0x738  | MakeNewObject — `f(a0=classID/name, a1=classID, a2=tags)`; private-name remap then `intuition NewObjectA(a0, a1, a2)` |
| -36  | 0x744  | DisposeObject — `f(a0=obj)`; passthrough to `intuition DisposeObject` |

All exported-vector calls are stack-arg (SAS/C-style) except the
small wrappers, which re-push a0/a1/a2 onto the stack for an inner
stack-arg function.  `a4` always ends up as the BSS block via a
relocated `lea _bss:l`.

## LibInit (AUTOINIT, code+0xd8)

`init(d0=libbase, a0=seglist, a6=sysbase)`:

1. Clears all 0x30 longs of the BSS block; stores lib base (+0x10),
   seglist (+0x0c), current SP (+0x80, bailout), exec version (+0x72),
   and the failure continuation +0x84 -> 0x120.
2. `jsr` open-all (0x764): dependency counter +0x8c; on first pass
   runs two dead ctor stubs then opens `exec.library` v33,
   `intuition.library` v33, `graphics.library` v33,
   `utility.library` v36 — each via `_openlib`, which stores the
   base+version and, on NULL, clears +0x10 and longjmps to +0x84.
3. `MakeClass(classID=0, superID="frameiclass", superPtr=0,
   instSize=0, flags=0)` -> bss+0x90; asserts non-NULL via `_check`
   (crash on failure — the pushed message string is never printed).
   Then installs the dispatcher hook entry (code+0x6ac) at
   `cl_Dispatcher.h_Entry` (class+8).
4. `OpenLibrary("iff.library", 0)`; on success calls iff -30 and
   stores the result as the textfield class at +0x94.  Failure is
   soft: +0x94 is just cleared, init still succeeds.
5. Returns bss+0x10 — the lib base, or 0 if a hard dependency failed
   (in which case the longjmp target at 0x120 has already run the
   once-latched cleanup of whatever did open).

## Vector -30 (0x738): MakeNewObject

Pushes a0/a1/a2 and calls the resolver at 0x6c8, which:

- if the first arg (a0, treated as a classID string pointer) is NULL,
  skips remapping;
- else bounded-compares it against `"getfileiclass"` (n=12) — match
  replaces the arg with bss+0x90 (the MakeClass'd class);
- else against `"textfieldgclass"` (n=14) — match replaces it with
  bss+0x94 (the iff-provided class);
- any other value passes through untouched.
- tail-calls `intuition.library` -636 `NewObjectA(classOrPtr,
  classID, tagList)` — i.e. the first argument may be either a
  private class pointer or a public classID string (NewObjectA's
  documented dual use), the second the public classID, the third the
  tag list.

The string compare (0xa90) is a dual-bound signed `strncmp`:
`f(s1, bound1=0xff, s2, bound2=n)` on the stack, callee pops 16
bytes.  It returns 0 on equal-prefix/NUL within bounds, ±(index+1)
style sign on mismatch — quirk, see findings.

## Vector -36 (0x744): DisposeObject

`f(a0=obj)` — loads intuition base from bss+0xbc, calls
`DisposeObject(a0)` (-642).  Contains a dead `push a0; pop a0`
sequence (compiler artifact).

## Private class dispatcher (entry 0x6ac, body 0x27c)

`h_Entry(a0=cl, a1=msg, a2=obj)` pushes (cl,obj,msg) and calls the
body `f(msg@8, obj@0xc, cl@0x10)`; epilogue `rtd #12`.

`d7 = MethodID - 0x101`; unsigned `> 0x101` selects index -1
(default).  Word-offset jump table at 0x470 (base 0x482):

- **OM_NEW (0x101)** -> 0x28e: `DoSuperMethod(msg,obj,cl)`; if the
  new object is non-NULL, `FindTagItem(IA_Width)` — absent =>
  `im_Width(+4) = 20`; `FindTagItem(IA_Height)` — absent =>
  `im_Height(+6) = 14`.  Returns the object.
- **IM_DRAW (0x202)** -> 0x2fe: `DoSuperMethod` first, then reads
  the object's im_Width/im_Height, builds a 13-point scaled border
  polygon (offsets by imp_Offset.X/Y at msg+8/+10), calls graphics
  `SetDrMd(rp, JAM2=1)` (-354), picks a pen — `imp_State==1` =>
  `dri->pens[6]` (else pen 0 without drinfo); other states =>
  `pens[2]` (else pen 1) — then `SetAPen` (-342), `Move` (-240) to
  the scaled (4,10) corner and `PolyDraw(rp,13,pts)` (-336).
  Returns 1.
- **everything else** -> 0x46a: plain `DoSuperMethod` passthrough.

`DoSuperMethod` (0x968) fetches `cl_Super` (+0x18) and funnels
through the `CallHook` trampoline (0x940), which pops
(hook,arg1,arg2) into (d1,d0->a2,...) — notably it returns 0 early
when **either the hook or the object argument is NULL**; that guard
is why `OM_NEW` with a NULL object short-circuits to 0 without any
superclass call.

## Scale helpers (0x208 / 0x242)

`f(ptr, arg)` — `d0 = (arg * ptr[-2]) / 20` and
`(arg * ptr[-4]) / 14` respectively, with a signed-division
sign fixup sequence (`eor` sign test, ±1 adjust) so negatives
truncate the same way SAS/C's `divs` path did.  `rtd #6`.

## Dependency open/close pairs

Four identical shapes (counter word, base, version copy in BSS):

| lib | open | close | cnt | ver | base | name @ | minver |
|-----|------|-------|-----|-----|------|--------|--------|
| exec      | 0x8fc | 0x920 | 0x9c | 0x9e | 0xa0 | 0x930 | 33 |
| utility   | 0x9bc | 0x9e0 | 0xa8 | 0xaa | 0xac | 0x9f0 | 36 |
| graphics  | 0xa00 | 0xa24 | 0xb0 | 0xb2 | 0xb4 | 0xa34 | 33 |
| intuition | 0xa48 | 0xa6c | 0xb8 | 0xba | 0xbc | 0xa7c | 33 |

Open order is exec, intuition, graphics, utility (see 0x764); close
order is the reverse (module counter pair at 0x998/0x9b0 wraps dead
ctor/dtor stubs).
