---
type: Finding
title: Public vector semantics inferred
description: LVO -30 relays to expname.library -30 and negates; no FD exists for boards.library.
timestamp: 2026-10-10T18:00:00Z
---

# Public vector semantics inferred

`boards.library` v1 (Torsten Bach) originally decoded expansion
manufacturer/product IDs to names; Richard Körber's expname.library
carried the same tables.  This binary's -30 stub calls
expname's -30 and returns `~result`, so the wrapper likely exists
to keep old boards.library clients working on top of expname —
i.e. -30 is plausibly the historical `BoardsGetName`-style query
(the E-language module in the old archive shows manufacturer/
product-name lookups).  Exact register signature and why the result
is inverted are unverified — flagged as open question.
