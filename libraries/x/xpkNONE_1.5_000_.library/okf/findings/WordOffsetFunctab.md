---
type: Finding
title: Word-offset function table
description: -1-marker offset table, not the absolute-longword form 1.4 used.
timestamp: 2026-10-10T09:20:00Z
---

# Word-offset function table

The AUTOINIT function table at .text+0x92 uses the offset form:
leading word `0xffff` (format marker), then ten signed word offsets
*relative to the table base* (0x92 — the marker itself is inside the
base), terminator `0xffff`. Contrast with xpkNONE_1.4, whose table is
absolute longwords placed *before* the RomTag.

Reserved slots encode 0xff6e = -0x92 → .text+0x00 (see
[EntryStubReuse](EntryStubReuse.md)) rather than pointing at a stub
function.

The rebuild reproduces the format via a two-pass link: a stub table
sizes the hunk, `nm` reads final symbol addresses, and
`genfunctab.py` emits `functab.s` with the real offsets.
