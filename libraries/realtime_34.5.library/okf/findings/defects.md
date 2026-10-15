---
file: defects
---
# Findings

- Functab entry 0 (Open) is 0 — MakeLibrary treats NULL
  entries as "don't install": the -6 slot keeps its
  default vector. Nonstandard but valid.
- Cleanest build in the realtime family: single hunk,
  declared==physical, plain RELOC32.
- Reserved LVOs -90..-114 all alias one +0x1a6 stub.
