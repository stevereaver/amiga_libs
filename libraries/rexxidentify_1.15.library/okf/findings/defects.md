---
file: defects
---
# Findings

- Six reloc slots target the 512B BSS hunk — the library keeps
  deferred state (command table pointers / ARexx port) there.
- Close-underflow: after two extra closes lib_OpenCnt wraps to
  0xffff and lib_Flags shows the deferred-expunge bit path; Remove +
  FreeMem observed on expunge under that state — upstream quirk,
  reproduced identically.
- The "DIFF" sibling (rexxidentify_1.15(DIFF)) is the identical
  build re-shipped with DREL16-encoded relocation tails — same
  offsets, 84 bytes smaller.
