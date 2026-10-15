---
file: defects
---
# Findings

- Packed-resident layout: RomTag, InitTable, functab and
  strings all inside the DATA hunk (same family as
  regexp_1.0's 8-hunk build but consolidated to 2).
- Functab entries are absolute longs; a second 16-entry
  absolute jump block at h1+0xc8 mirrors internal h0
  entries (SAS/C near/far thunk table).
- No invalid accesses.
