---
file: defects
---
# Findings

- Four literal-0 functab holes -> h0+0 `moveq#-1` stub
  (unimplemented slots kept in the table).
- Body grew +0x15c vs the 6.1s sibling with a reshuffled
  vector order — a genuinely different build, not a re-version.
