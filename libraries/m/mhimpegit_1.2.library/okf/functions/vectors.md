# mhimpegit.library 1.2 — vector map

Functab: 14 absolute-long entries in the DATA hunk (data+0x56), `-1`
terminated at +0x8e. rt_EndSkip also points at data+0x56. All public
entries use a register ABI (lib base in a6; obj in a3; args in a0/d0/d1).

## Resident/init

- **Packed RomTag @ data+0x3c**: `4afc` + unaligned longs
  `{matchtag→+0x3c, endskip→+0x56, flags=0, ver=1, type=9, pri=0,
  name→+0, idstr→+0x12, init→code+4}`.  flags byte is 0 — no AUTOINIT
  bit; InitResident calls rt_Init directly.
- **LibInit (code+4)**: `(a0=seglist→d7, a6=execbase→a5)`
  execbase→data+0x92; `OpenLibrary("dos.library",0)`→data+0x96
  (result unchecked); `MakeLibrary(data+0x56,0,0,42,0)`→data+0x9a;
  on NULL returns 0 (via `beq` into a `moveq #0` mid-instruction).
  Fills: lib+8 ln_Type=9, lib+10 ln_Name=data+0, lib+14 flags=6,
  lib+20 ver=1, lib+22 rev=2, lib+24 idstr=data+0x12,
  lib+34 seglist, lib+38 execbase; `AddLibrary(lib)`; returns base.
- **Open** (-6, +0x8e): OpenCnt.w++, `flags &= ~8`, returns a6.
- **Close** (-12, +0xa6): if OpenCnt>0: --, and if 0 + flag3 → expunge.
- **Expunge** (-18, +0xd8): OpenCnt>0 → flag3|=, ret 0.  Else:
  Remove(lib), seg=lib+34, FreeMem(lib−NegSize, Neg+PosSize),
  CloseLibrary(data+0x96) if set, clear it, return seg.
- **-24 stub** (+0x13e): `moveq #0,d0; rts` + nop pad.

## Public

- **Create** (-30, +0x144), args `a0=tag0, d0=tag1`:
  `OpenLibrary("prelude.library",5)` → data+0x114 (stored before
  checking); gate quirk — **fails only if `lib+20==5 && lib+22<2`**
  (any other version passes); then bit0 of `*(prelude+0x38)+0x15`
  must be set.  AllocVec **16B** (flags 0x10000 = CLEAR only) obj
  `{+0=arg0, +4=arg1, +8=count, +12=listptr}`; AllocVec 12B
  (0x10001 PUBLIC|CLEAR) list block, NewList'd — **unchecked, NULL
  deref on OOM**.  Copies the 32B template at data+0xac to the stack
  and calls prelude@-90 with
  `{0x80000032:obj+0, 0x80000033:obj+4, 0x8000003f:99, TAG_DONE}`,
  clears `*(prelude+0x8e)+0x10`, returns obj.
  All failure paths return 0 but **leave prelude open**.
- **Destroy** (-36, +0x1fc), arg `a3=obj`: NULL → return (prelude left
  open).  Else `CloseLibrary(prelude)` first, then RemHead/FreeVec
  every node, FreeVec(obj).  The 12B list block is **never freed**.
- **Append** (-42, +0x244), args `a0=v0, d0=v1, a3=obj`: NULL obj →
  `v1 & 0xffff0000` (stale-arg quirk).  AllocVec 18B node (0x10001,
  **unchecked**) `{+8=v0,+12=v1,+16.w=0}`, AddTail(obj+12), obj+8++.
  If `*(prelude+0x8e)+0x10` nonzero: node+16.w=1 and
  prelude@-60(a0=v0, d0=v1, d1=0x1008, d2=22050).  Returns 1.
- **Pop** (-48, +0x2ba), arg `a3=obj`: NULL → 0.  If prelude flag
  `*(prelude+0x8e)+0x10` >= obj+8 count (unsigned) → 0.  Else
  RemHead, r=node+8, FreeVec node; count-- if nonzero; return r.
- **Query** (-54, +0x30a), arg `a3=obj`: 1 if !obj; else
  `*(prelude+0x8e)+0x10`==0 → 1, else 0.  (Clean boolean — the 4.0
  build returned a sloppy `(obj&~0xff)|!flag`.)
- **Iterate** (-60, +0x32e), arg `a3=obj`: NULL → ret.  a5 =
  `*(obj+12)` = lh_Head; loop: if node+16.w==0 →
  prelude@-60(node+8, node+12, 0x1008, 22050), node+16.w=1;
  advance node=node->succ; stop when new node's succ is 0.
  Empty list walks the tail sentinel inside the 12B list block and
  reads +16 out of bounds.
- **Drain** (-66, +0x382), arg `a3=obj`: NULL → ret.
  prelude@-84(d0=128 literal), prelude@-36, dos Delay(35) via
  data+0x96, RemHead/FreeVec drain, clears prelude flag + obj+8.
- **-72 stub** (+0x3de): `push a4; lea data,a4; pop a4; rts` —
  stale d0 (the data reload is dead code).
- **Classify** (-78, +0x3ea), arg `d1=code`: subtraction chain —
  `{1,2,3,10,11,12,20,21,30,31,40,41}` → 1;
  `1000`→"MPEGit" (data+0xdc), `1001`→"1.2 (20.01.2017)" (data+0xe4),
  `1002`→"Thomas Wenzel" (data+0xf6), `1010`→1; all else fall
  through a `bras` that lands mid-instruction on `moveq #0,d0` → 0.
- **Dispatch** (-84, +0x470), args `d0=op, d1=val, a3=obj`: NULL obj or
  `op.w >= 7` → ret (word compare; high bits ignored).  Copies the 16B
  template at data+0x104 `{0x8000003f,0,0,0}` to the stack, then:
  op0 → `{3f, min(v,100)}`; op3 → `{3c, 15*min(v,100)/50}`;
  op5 → `{3d, 15*min/50}`; op6 → `{3b, 15*min/50}`;
  **ops 1,2,4 make no call** (4.0 sent `{3a, min}` for op1).
  prelude@-90(tags).  `15*x/50` via a shared unsigned div subroutine
  (code+0x60e, divuw-based; 0x5dc is a signed wrapper).

## Helpers

- `+0x530`: memcpy — 24B unrolled loop + computed-goto tail.
- `+0x5c4/+0x5c8`: NewList (a0 or stack arg): tail=0, tailpred=&head,
  head=&tail.
- `+0x5dc`: signed 32÷16 wrapper (negates negatives, calls +0x60e).
- `+0x60e`: unsigned d0.l / d1.w division (divuw bit-normalise path).
