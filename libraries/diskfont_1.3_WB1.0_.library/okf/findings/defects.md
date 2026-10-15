---
file: defects
---
# Findings

- h8 DATA and h9 CODE are zero-length linker artifacts kept
  in the file — preserved verbatim.
- Same family shape as 31.9/33.16 but older: smaller h0,
  different functab order, two-module cross-hunk vectors.
- Expunge in the oracle returns 0 while still open-checked;
  deferred-expunge flag handling differs from later builds.
