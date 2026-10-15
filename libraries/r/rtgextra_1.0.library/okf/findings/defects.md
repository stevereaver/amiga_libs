---
file: defects
---
# Findings

- h1 is tagged CODE though it holds only the functab + strings.
- Resident name/id/init pointers are stored relative to OTHER
  hunks and relocated (name->h1+0x40, init->h2+4).
- functab has a literal-0 hole at entry 3 -> h0+0 stub.
- h2's InitTable is followed by 36B of extra relocated cells —
  not part of the standard 4-field table; hand-built init data.
