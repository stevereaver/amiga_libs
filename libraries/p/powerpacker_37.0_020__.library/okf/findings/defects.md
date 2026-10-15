---
file: defects
---
# Findings

- **Version mismatch**: datatab writes lib_Version=36,
  lib_Revision=10 while the resident claims ver 37 and the
  idstring says "pplib 020+ 37.0 (06.11.96)". Version
  queries against lib_Version see 36.10, not 37.0.
- Hunk alloc size (0x5ad longs) exceeds body (0x5a3): the
  40B trailing pad is deliberately used as runtime globals
  (dep bases, saved FreeMem vector, 12B descriptor) — an
  embedded BSS tail inside the CODE hunk allocation.
- initfn SetFunction-patches exec FreeMem(-210) globally for
  the lib's whole lifetime; expunge only restores it when
  the vector jump-target still equals the hook address —
  a later SetFunction by another tool leaves the patch (and
  the old-vector stash at h0+0x16a0) orphaned.
- Runtime: ~9.35M invalid accesses counted — crunch core
  walks raw buffers; deterministic (identical on rebuild).
- Dep bases live in the hunk pad (h0+0x16a8/c/0), not in
  the library data segment; lib+0x24 holds the seglist.
- intuition/graphics opened at init but unused in all
  oracle-traced paths (progress/UI paths not triggered).
