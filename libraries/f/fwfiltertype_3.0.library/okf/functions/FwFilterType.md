---
type: Function
title: FwFilterType
description: Compares 5 type bytes at field+0x0c against "alpha"; returns 3 and a "fwpenpal.library" pointer on match.
lvo: -30
tags: [user-function, filter]
timestamp: 2026-10-15T02:00:00Z
---

# Signature

```c
ULONG FwFilterType(UBYTE *field, STRPTR *out, ULONG unused);
/*                  a0           a1            d0          */
```

# Semantics

- Compares **5 bytes** at `field + 0x0c` against `"alpha"` — the `dbne`
  loop is seeded `d0=4`, so it iterates 5 times (offsets 0..4) testing
  the full `"alpha"`.  (An earlier doc revision claimed only `"alph"`;
  oracle-verified that `alphx` fails and `alpha` matches.)
- On match: `d7 = 3`; if `out != NULL`, `*out = "fwpenpal.library"`.
- On mismatch: `d7 = 0`; if `out != NULL`, `*out = NULL` — the miss
  path enters the store block mid-instruction (see DeadCompare) and
  executes `clr.l (a4)`.
- If `out == NULL` (`a1=0`), the store block is skipped entirely.
- Return value: `move.w d7,d0` writes only the low word — the upper 16
  bits of d0 carry whatever the preceding `ext.l`/`subq.l` left, so
  callers must mask to a word (oracle observed `0xffff0000` on the miss
  path, `3` on match).
- The `d0` argument is pushed into the reserved stack slot at entry and
  never read — a genuinely unused third parameter.

# Notes

- Sole user function — the binary is essentially a type-name
  translation service: field `+0x0c == "alpha"` maps to the
  `"fwpenpal.library"` string (SoftWood's PenPal family naming).
- Prologue is unusual: `subq.w #4,a7` + `movem.l d7/a4-a5,-(a7)` — the
  extra 4-byte frame slot holds the unused d0 store.
