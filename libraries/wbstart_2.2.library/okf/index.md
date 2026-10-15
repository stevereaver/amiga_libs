---
bundle: wbstart_2.2.library
status: complete
updated: 2026-10-16
---
# wbstart.library 2.2 (18.9.96) "WBStart Handler"

Workbook-style program launcher library: `WBStart(tagList)` hands
the request to a private "WBStart Handler" process (spawned once
via dos CreateNewProc with an NP_Entry tag pointing into the CODE
hunk) which resolves the tool through icon.library and starts it
as a new process with a WB-like startup message.  NON-AUTOINIT
packed RomTag (rt_Flags=0): rt_Init runs init code that calls
exec MakeLibrary(-84)+AddLibrary(-396) itself.  SAS/C small-data
build: a4 = DATA+0x7ffe, globals live in the 40-byte DATA
allocation whose body defines only 4 bytes.  Requires exec V39+
(initfn returns 0 below that) and dos/icon/utility V39 opened by
the handler at first WBStart; dospath.library v1 is used
opportunistically to clone the CLI command path.

- `structures/layout.md` — hunk map, RomTag, functab, DATA globals
- `functions/vectors.md` — LVO table + internal entry points
- `findings/defects.md` — quirks
