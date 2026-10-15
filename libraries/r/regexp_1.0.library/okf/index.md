---
bundle: regexp_1.0.library
status: complete
updated: 2026-10-15
---
# regexp 1.0 'Version 1.0'

Minimal regular-expression library. AUTOINIT resident (packed —
no MatchWord/MatchTag padding), but the InitTable lives in a
separate DATA hunk and its function-table/initfn fields are
relocatable zeros pointing into other hunks.

- `structures/layout.md` — 8-hunk map, packed resident
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
