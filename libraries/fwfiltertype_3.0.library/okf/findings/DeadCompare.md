---
type: Finding
title: Dead compare in FwFilterType
timestamp: 2026-10-10T19:15:00Z
---

# Dead `cmpi.w #$4294,d0`

FwFilterType ends the store path with `cmpi.w #$4294,d0` — the condition
flags are never consumed before `rts`. d0 at that point is the result of
`ext.l(d7)-3` (0 on the store path), so the compare is constant. Leftover
code or compiler artefact; no functional effect. Not reproduced in C
(documented here only).

Also of note: the d0 argument is moved into the stack frame at entry and
never read — a genuinely unused third parameter.
