---
type: Finding
title: Reserved LVO -96
description: Undocumented jump-table slot between PopChunk and EntryHandler.
timestamp: 2026-10-10T18:00:00Z
---

# Reserved LVO -96

The NDK FD marks a gap after PopChunk: `##bias 102` — one slot is
reserved between LVO -90 (PopChunk) and LVO -102 (EntryHandler).

In the binary, that slot contains a `moveq #0,d0 / rts` stub at
0x1ba — the same stub that serves ExtFunc (LVO -24).  Calling it is
a harmless no-op returning 0.

The stub is shared, not duplicated: table entries [3] and [15] both
hold offset 0x0162 (relative to the table at 0x58 → code 0x1ba).
This was presumably a private/withdrawn entry point that Commodore
stubbed out rather than renumbering the vector table.
