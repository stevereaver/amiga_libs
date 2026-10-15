---
bundle: realtime_37.3.library
status: complete
updated: 2026-10-15
---
# realtime.library 37.3 (10.12.92)

Commodore real-time player library — CIA-timer scheduling core
(ciaa/ciab.resource ICR interrupts) + conductor/player list
management, SAS/C small-data build (A4 = data-hunk base "EndSkip").

2 hunks: h0 CODE 0x4ae longs (4792B) + h1 DATA (declared alloc
0x19 longs / 100B, but only 4 longs / 16B stored — the tail is a
BSS-like globals area zeroed by InitCEnv). AUTOINIT resident@h0+4
ver 37, InitTable@h0+0x4a, 14-entry absolute-long functab@h0+0x7c.
Both hunks carry full HUNK_SYMBOL tables (40 + 5 symbols) — every
internal function is named.

- `structures/layout.md` — hunk map, resident, InitTable, data seg
- `functions/vectors.md` — LVO table + dependency calls
- `findings/defects.md` — quirks + deltas vs 34.5 / 40.2
