# Layout

- 5 hunks, all code except h1 (DATA InitTable) — h4 CODE holds the functab + name/id strings.
- Hunk bodies: h0 3948B, h1 16B, h2 44B, h3 24B, h4 100B.
- HUNK_DEBUG LINE records interleaved between hunk records; HUNK_SYMBOL block near file end with names `_RGHitTest`, `_RGCallMethod`, `__LibFuncs.o`, `__LibID`, `__LibName`, `__LibFuncTab`.
- RELOC32 groups: h0->h0 (2), h0->h1 (1), h0->h2 (2), h0->h3 (2), h0->h4 (4) and further groups for h2/h3/h4.
- Library private size 0x7c; standard library header fields initialised by InitTable/relocations.
