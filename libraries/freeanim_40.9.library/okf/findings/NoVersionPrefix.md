---
type: Finding
title: ID string lacks $VER: prefix
description: "freeanim.library 40.9 (11.8.95)" is invisible to the Version command.
timestamp: 2026-10-10T18:00:00Z
---

# ID string lacks `$VER:` prefix

RT_IDSTRING does not start with `$VER:` — Version will not report
this library.  Also note there is a stray `4e 71` (NOP opcode) at the
odd address 0x51 between the id string and the InitTable, and another
NOP word at 0x8e between the InitStruct terminator and the first
function — likely generator padding artifacts.
