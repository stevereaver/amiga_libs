---
type: Finding
title: Quirks
description: Oddities found in the shipped binary.
timestamp: 2026-10-10T21:10:00Z
---

# Quirks

- **RomTag version lie + self-patch**: `rt_Version` is **2** and
  init writes `lib_Revision = 2`, although file and IdString
  advertise 45.2 — same trick as the 45.1 original, but this
  build *also* patches the RomTag `RT_VERSION` byte with 2 at
  runtime (self-modifying write into the data hunk).
- **NULL-base CloseLibrary**: on init failure `CloseLibs` calls
  `CloseLibrary` on all three support-base slots
  unconditionally, including NULL ones — a crash path preserved
  verbatim.
- **noncanonical `tst.l An` opcodes**: the WBStart tag loop tests
  the `NextTagItem` result with `tst.l a0` (0x4a88) and the args
  pointer with `tst.l a3` (0x4a8b) — encodings outside the
  documented TST EA set that real 68k CPUs nevertheless execute
  as a plain test (typical Aztec/SAS-era compiler output).
- **`add.l a7,dN` forms**: 0xd68f/0xd48f/0xda8f use An as the
  source `<ea>` of ADD.L (noncanonical vs ADDA) — again valid
  silicon behaviour, just outside the canonical encoding.
- **`lea 0.w,aN` for NULL**: pointers are cleared with
  `lea 0x0,%aN` absolute-word instructions (0x4bf8/0x47f8/0x49f8/
  0x41f8) instead of `suba`/`moveq` — compiled-C flavour.
- **stray tail word**: the code hunk ends with four zero pad
  words followed by `0x0002` (code+0x59a..0x5a3) — a leftover
  constant shipped verbatim.
- **non-sorted RELOC32 group**: the CODE hunk's first reloc
  group stores offsets `{1dc, 1cc}` (the `strncat` call site
  before `strncpy`); most linkers emit ascending order.
- **Inverted result**: WBStart returns **0** on success and
  **20** (RETURN_ERROR) on any failure, including a missing name
  tag — matching 45.1's convention, inverting the workbench BOOL.
- **Dead code**: the code hunk ends with two libc-style string
  routines (strcat/strcpy shapes) that are never called —
  compiler runtime pulled in but unused.
- **Module entry returns -1** — not loadable as a program.
- **NULL-safe calls relied on**: `FreeVec(NULL)`, `UnLock(0)` are
  invoked unconditionally.
