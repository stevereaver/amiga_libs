---
type: Findings
title: mpega.library 2.4 (PPC) quirks
---

# Findings / quirks

- Resident embedded in the DATA hunk at +0x100 rather than the
  code hunk — relies on exec's InitResident scanning all loaded
  hunks.  The hunk0+0 entry point is a stub returning -1.
- Code is `a4`-relative to the DATA hunk (GCC a4-data model);
  every entry does `lea h1,a4` via a relocated operand.
- InitData uses the byte-command format with 24-bit offsets
  (`e0`) and embedded longs that carry real hunk relocations
  (LN_NAME at +0xa -> h1+0x54, idstring at +0x18 -> h1+0x64).
- Under stubbed ppc.library the initfn completes its PPC load
  attempt (direct name then LIBS: fallback), issues follow-up ppc
  calls, closes dos/ppc, and returns 0 — i.e. the library does
  not keep dos/ppc bases open after init.
