---
bundle: Cdplayer_1.0.library
status: complete
updated: 2026-10-15
---
# cdplayer 1.0 'Version 1.0'

CD-audio player library — dispatches commands to a CD device via
exec PutMsg (-456) and owns a reply context. AUTOINIT packed
resident; InitTable in the DATA hunk with relocated-zero fields.

- `structures/layout.md` — 3-hunk map, packed resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
