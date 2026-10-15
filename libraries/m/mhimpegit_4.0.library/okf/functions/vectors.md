# mhimpegit.library 4.0 — vector map

Functab: 14 absolute-long entries in the DATA hunk (data+0x14), `-1`
terminated. All public entries use a register ABI (lib base in a6).

## Lifecycle

- **LibInit** (code+4, via InitTable.initRoutine): BSS+0=lib,
  lib+38=SysBase, lib+34=seglist, then helper: ExecBase→BSS+4 and lib+38,
  OpenLibrary("dos.library",36)→BSS+8 and lib+42. On DOS-open failure:
  closes BSS+8 and frees the library block via Neg/PosSize (+16/+18).
- **Open** (-6): `OpenCnt.w@+32++`, `flags@+14 &= ~8`, returns a6.
- **Close** (-12): `OpenCnt.w--`; if 0 and flag3 set → expunge body.
  Else returns 0.
- **Expunge** (-18): if OpenCnt != 0 → `flags@+14 |= 8`, returns 0.
- **Expunge body** (shared helper): Remove(lib), CloseLibrary(BSS+8),
  BSS+8=0, FreeMem(lib−NegSize, Neg+PosSize), returns seglist (lib+34).
- **-24 stub**: `clr.l d0; rts`.

## Public

- **Create** (-30, code+0x268), args `a0=tag0val, d0=tag1val`:
  `OpenLibrary("prelude.library",4)` → BSS+12 unconditionally; checks a
  **feature gate** — bit0 of `*(prelude+0x38)+0x15` must be set. AllocVec
  18B (CLEAR) object `{+0=arg0, +4=arg1, +8=list, +12=count, +16=0}`,
  plus AllocVec 12B list block (PUBLIC|CLEAR) which is NewList'd.
  Calls prelude@-90 with taglist
  `{0x80000032: arg0, 0x80000033: arg1, 0x8000003f: 100, TAG_DONE}`,
  then clears the prelude flag `*(prelude+0x8e)+0x10`. Any failure →
  teardown helper + 0.
- **Destroy** (-36, code+0x34c), arg `a3=obj`: teardown helper — RemHead/
  FreeVec every node, FreeVec the 12B list block, FreeVec the object,
  CloseLibrary(BSS+12), BSS+12=0. Returns helper's leftover d0 (not set).
- **Append** (-42, code+0x35a), args `a0=v0, d0=v1, a3=obj`: AllocVec 18B
  node `{+8=v0, +12=v1, +16.w=0}` — **result not checked** — AddTail into
  obj's list, count++. If prelude flag `*(prelude+0x8e)+0x10` nonzero:
  marks node+16.w=1 and calls prelude@-60(v0, v1, d1.w=0x1008, d2=0).
  Returns 1; returns `v1 & 0xffff0000` when obj is NULL.
- **Pop** (-48, code+0x3d2), arg `a3=obj`: if prelude flag (ULONG)
  >= obj count (unsigned) → 0. Else RemHead, return node+8, FreeVec,
  count--. Empty list → 0.
- **Query** (-54, code+0x42a), arg `a3=obj`: `seq d0;neg.b d0` on the raw
  flag — returns `(obj & 0xffffff00) | (flag==0 ? 1 : 0)`; for NULL obj
  returns 1.
- **Iterate** (-60, code+0x446), arg `a3=obj`: walks the list from the
  header block itself, calling prelude@-60(node+8, node+12, d1.w=0x1008,
  d2=0) and marking node+16.w=1 for every entry whose +16 word is 0 —
  **including the 12-byte header block treated as a pseudo-node** (reads
  +12/+16 out of bounds). Stops when the walked node's [0] is NULL.
- **Drain** (-66, code+0x48a), arg `a3=obj`: prelude@-84 (d0.w=0x80 on
  stale d0) then prelude@-36, dos Delay(35) via BSS+8, then RemHead/
  FreeVec drain loop, clears the prelude flag and the count.
- **-72 stub** (code+0x4e8): bare `rts` — returns whatever was in d0.
- **Classify** (-78, code+0x510), arg `d1=code`: maps codes to success/0
  or string pointers —
  `{1,2,3,10,11,12,20,21,30,31,40,41}` → 1;
  `1000`→"MPEGit", `1001`→"4.0 (22.05.2022)", `1002`→"Thomas Wenzel";
  `1010`→1; everything else → 0. All unsigned compares.
- **Dispatch** (-84, code+0x590), args `d0=op, d1=val, a3=obj`: no-op for
  NULL obj or `op.w > 6` (word compare, high bits ignored). Builds a
  `{tag, value, 0, 0}` taglist on stack, prelude@-90:
  op0→{0x8000003f, min(v,100)}, op1→{0x8000003a, min(v,100)},
  op3→{0x8000003c, 15·min(v,100)/50}, op5→{0x8000003d, 15·min(v,100)/50},
  op6→{0x8000003b, 15·min(v,100)/50}; ops 2 and 4 make no call.
  min() is unsigned; 15·x/50 uses `divu.l`.
