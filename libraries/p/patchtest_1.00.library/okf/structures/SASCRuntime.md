---
type: Structure
title: SAS/C per-open runtime
---

# SAS/C "private data per opener" model

LibInit copies the 28-byte InitTable area into base+0x3c and
optionally allocates a `{ULONG count; ULONG offsets[]}` fixup
buffer (from the data hunk tail; empty here).

Each LibOpen allocates `30 + dataSize` bytes (jump-table
prefix + full base), copies the master image, applies the
fixup offsets to rebase the private copy, then calls the
per-open user init.  lib_OpenCnt lives in the master base;
the copy's +0x32 field points back at the parent.

Effect for this library: one `OpenLibrary("intuition.library")`
per open and one `CloseLibrary` per close -- which the
reconstruction preserves directly on the shared base.
