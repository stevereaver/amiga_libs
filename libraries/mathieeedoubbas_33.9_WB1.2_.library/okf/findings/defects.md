---
file: defects
---
# Findings

- Ships with a full HUNK_SYMBOL debug hunk — every internal
  routine named (dfi1-6, dfa*, dfd*, dfm*, dfcmp*, dftst,
  badtrap, fpoptrap, _CXA/C/D/M/N/S/T/V55...).
- Flags 0x81 (AUTOINIT|bit0) as other WB math libs.
- Two empty trailing hunks (CODE + DATA, both 0 longs).
- Deterministic unmapped table reads 0xffffff2e+ under stubs.
