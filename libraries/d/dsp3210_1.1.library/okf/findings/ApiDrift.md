---
type: Finding
title: API drift vs the v7 FD
timestamp: 2026-10-10T20:10:00Z
---

# API drift vs the v7 FD

This 1.1 (2020-01-03) exports only the first two functions of what
became an 11-function API (`dsp3210_lib.fd` in the Aminet v7.x
package). Two observable ABI differences from the FD signatures:

- `DSPRelocate`'s third argument is iterated as a plain
  `{const char *name, ULONG value}` pair array — the current FD calls
  it `globsymhdr`, a `DSP3210GlobSymHeader` with a magic ID and a
  MinList. The pair array is a *subset* behavior; a v7-style caller
  passing the header struct would not work here.
- Both user functions read an extra `d0` bound used to cap the symbol
  table (`symtabOff + symCount*18 <= d0`). The FD shows no such
  argument — presumably the blob size, dropped or relocated in later
  versions.

Callers built against the modern headers should treat this build as
a distinct, older ABI.
