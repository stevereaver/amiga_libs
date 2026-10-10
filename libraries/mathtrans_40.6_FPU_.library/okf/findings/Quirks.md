---
type: Finding
title: Quirks
description: Oddities found in the shipped binary.
---

# Quirks

1. **RT_ENDSKIP points at the InitTable** (hunk+0x72), not
   at the end of the module — resident-tag scanning resumes
   mid-structure.  Harmless (everything before it is the
   RomTag itself) but unusual.

2. **The IEEE->FFP edge tree has dead-ish paths**: in
   `_fie_case1c`, `andi.w #0xfeff` + `tst.l` + either `rts`
   (d0==0) or `moveq #0` both yield 0 — the andi/tst only
   matters because a lone sign bit8 makes d0 nonzero before
   the clear.

3. **`lsl.w #8,d0` at the case2 entry is dead work** — it
   runs immediately before `moveq #-1,d0` overwrites d0.
   Only flags are touched, and `moveq` resets them anyway.

4. **Error convention is `0xFFFFFFFF` + V set** — overflowed
   or unrepresentable IEEE inputs (infinities, huge
   exponents) return all-ones; callers are expected to check
   the V flag.  Tiny/subnormal IEEE values clamp to FFP 0.

5. **ExtFunc (-24) points at the bare `moveq #0,rts` module
   entry** — returns 0, same as the sibling libraries.

6. **DELEXP lives in a private byte** at base+0x2a bit3,
   not in lib_Flags — same as the sibling 40.6 builds.
