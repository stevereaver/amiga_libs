---
file: defects
---
# Findings

- Packed Resident again (fields at +0x12/+0x16/+0x1a).
- initfn opens utility.library v37 just to stamp version fields,
  then closes it — initialization-time only dependency.
- 5 trailing word-offset entries all point at the same
  unimplemented-stub (+0x168).
- resource names ciaa.resource/ciab.resource kept in a separate
  DATA hunk; conductor allocation uses those at player-open.
