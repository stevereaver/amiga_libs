---
type: Function
title: WBStart
description: Tag-driven OpenWorkbenchObjectA wrapper with lock/search-path resolution.
lvo: -36
registers: a0 taglist, a6 base -> d0 0|20
timestamp: 2026-10-10T21:10:00Z
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

The tag scan uses the 68000-illegal `tst.l a0` form (0x4a88) to
test the NextTagItem result — see [Quirks](../findings/Quirks.md).

Then, only when a name was given:

- if NumArgs && Args: `AllocVec((nargs+1)*16, 0)` and emit per
  arg the pair `{WBOPENA_ArgLock, a[0]}, {WBOPENA_ArgName, a[1]}`
  plus a `TAG_DONE` terminator; on AllocVec failure the whole
  call is skipped (internal sentinel -1).
- if a lock is set: `oldcd = CurrentDir(lock)`.
- `StartObject(name, wbtags)` resolves the name itself
  (emulation-specific, see below); on success the vector
  **returns 0, else 20 (RETURN_ERROR)** — the same inverted
  convention as the 45.1 original.
- restores `CurrentDir(oldcd)` when a lock was installed,
  `FreeVec(wbtags)` (called unconditionally — FreeVec(NULL)
  relied on as safe), `UnLock(lock)` — `UnLock(0)` likewise.

## StartObject (private, emulation-specific)

Replaces the 45.1 PathPart/Lock approach with explicit probing:

1. Scan the name for `':'`:
   - `"VOL:"` (trailing colon) → `OpenWorkbenchObjectA(name)`
     directly on the volume root.
   - `"dev:dir/file"` → `LockObjectOrInfo(name)`; on success
     `ParentDir(lock)` + `CurrentDir` + open `FilePart(name)`;
     restore dir, unlock both locks.
2. No colon — try `LockObjectOrInfo(name)` in the current dir;
   on hit open it, else walk the **Workbench search path**:
   `WorkbenchControlA(WBCTRLA_DuplicateSearchPath)` gives a
   BPTR-chained list of `{next, dirlock}` elements; for each,
   `CurrentDir(element->lock)` and retry the lock probe; first
   hit opens the object.  If nothing matched,
   `PrintFault(IoErr(), name)` reports the dos fault.  The path
   list is freed with `WBCTRLA_FreeSearchPath`.
3. `LockObjectOrInfo(name)`: `Lock(name, ACCESS_READ)`, else
   build `"<name>.info"` in a 256-byte stack buffer (bounded
   `copypad`/`appendn` helpers) and lock that — i.e. it accepts
   an icon-only Tool as well.

All `OpenWorkbenchObjectA` results are word-extended BOOLs;
non-zero maps to the WBStart success return of 0.
