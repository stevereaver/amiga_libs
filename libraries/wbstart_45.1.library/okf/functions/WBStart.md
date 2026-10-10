---
type: Function
title: WBStart
description: Tag-driven OpenWorkbenchObjectA wrapper with optional CD override and arg pairs.
lvo: -36
registers: a0 taglist, a6 base -> d0 0|20
timestamp: 2026-10-10T20:00:00Z
---

# ``LONG WBStart(struct TagItem *tags)``

**LVO -36**

Iterates `NextTagItem` (utility) over the list:

| tag (TAG_USER+) | effect |
|---|---|
| 1 `WBSTARTA_Name`    | STRPTR object name — **required** |
| 2 `WBSTARTA_Lock`    | path string; `UnLock` current, `Lock(path, ACCESS_READ)` |
| 3 `WBSTARTA_DupLock` | BPTR; `UnLock` current, `DupLock` it |
| 4, 5                 | accepted, ignored |
| 6 `WBSTARTA_NumArgs` | count of arg pairs |
| 7 `WBSTARTA_Args`    | array of `{lock, name}` LONG pairs |

Then, only when a name was given:

- if NumArgs && Args: `AllocVec((nargs+1)*16, 0)` and emit per arg
  the pair `{WBOPENA_ArgLock, a[0]}, {WBOPENA_ArgName, a[1]}` plus
  a `TAG_DONE` terminator; alloc failure skips the whole call.
- else the tag pointer is 0 (no extra tags).
- if a lock is set: `oldcd = CurrentDir(lock)`; otherwise
  `p = PathPart(name)` — when `p != name` the name is truncated at
  p, `Lock(dir, ACCESS_READ)` + `CurrentDir`, the byte restored and
  `name = p` (+1 when the separator was `'/'`).
- `OpenWorkbenchObjectA(name, wbtags)`; **returns 0 on success,
  20 (RETURN_FAIL) otherwise** — note the inversion vs. the
  workbench BOOL.
- restores `CurrentDir(oldcd)` when a lock was installed,
  `FreeVec(wbtags)` (called unconditionally — FreeVec(NULL) relied
  on as safe), `UnLock(lock)`.

Returns 20 also when no name tag was supplied.
