---
file: defects
---
# Findings

- 7.1 vs 7.0: same layout/vector map; 3870 differing
  bytes are mostly reloc fixups + small code deltas —
  id string bumped to 7.1 (12.12.2021).
- Container cookie 0x00fc2011, DSPCOMPAT env string,
  dos.library dep — unchanged from 7.0.
- Reserved slots -24/-30/-36/-42/-72 return -1 or 0
  without side effects when given invalid args.
