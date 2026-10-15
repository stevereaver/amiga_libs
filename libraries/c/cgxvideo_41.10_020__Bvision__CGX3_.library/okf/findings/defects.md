---
file: defects
---
# Findings

- **020 vs 040 builds differ by 1 byte only** (file 0xab, the
  '2'/'4' of "68020/68040 Version" in $VER). Identical code,
  data, relocs and symbol tail — the CPU variants are a
  re-label, not a re-codegen.
- **utility/layers open-fail falls into the success tail**: if
  OpenLibrary("utility.library",39) or ("layers.library",39)
  returns NULL, Open jumps to the success path (opencnt++,
  returns libbase) — later deps are never opened and (on the
  layers path) the patches are never installed, yet the lib
  reports success.
- **CloseLibrary(NULL) on dos-fail**: the dos.library failure
  path CloseLibrary's D0 (the NULL result) instead of the
  expansion.library base still held in A2 — and the expansion
  base is never closed on ANY failure path (anchor/leak).
- **Close underflows opencnt / never closes**: -12 decrements
  lib+0x20 unconditionally and never closes the deps; -18
  Expunge is a stub returning 0 — the lib (and its layers
  patches) can never be removed once opened.
- **4 of 6 CYBI records have no in-file installer**: only the
  two layers patch records are wired via the h1 patch table;
  the other four (intuition MoveWindow/SizeWindow/
  MoveSizeWindow/ActivateWindow-shaped hooks) rely on an
  external scanner (presumably cgxsystem.library) finding the
  'CYBI' markers — they look dead in isolation.
- **h3 is a KPrintF debug stub** reachable from one h2 site
  (JMP _kprintf @h2+0x516, inside the ActivateWindow-shaped
  hook impl h2+0x434); it carries the file's only HUNK_SYMBOL
  hunk (29 symbols incl. private labels ps0/ps1).
- **Uninitialized D0 returns**: -36/-48/-60/-66 can fall
  through with whatever D0 survived (under synthetic args a
  string-tail byte, 0x6e2e6c69 — deterministic, not a real
  return value).
- Runtime under machine68k: deterministic; ~25M invalid
  accesses (SetVLayerAttrTagList walks the unmapped stub
  taglist), identical count on rebuild.
