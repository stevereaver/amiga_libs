---
file: defects
---
# Findings

- Inverted layout: InitTable in DATA hunk, functab in CODE
  hunk — resident Init field relocates to a different hunk.
- Id string lacks the conventional '$VER: ' prefix.
- Deterministic unmapped reads (0xfffffac+ negative addr
  walk) in a vector path under stub emulation.
