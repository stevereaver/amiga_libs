---
file: defects
---
# Findings

- Lazy dependency opens: asl.library/intuition.library open on
  first use of LVO -54, keymap.library on -60 (which then LoadSegs
  `sys:devs/keymaps/`).
- Prefs write path uses `sys:s/mcpliberr.log` for diagnostics.
- Underflow on repeated Close wraps lib_OpenCnt to 0xffff — deferred
  expunge engages on next expunge call (upstream quirk, identical
  in rebuild).
