---
type: Finding
title: ID string lacks $VER: prefix
description: Version string is "freeanim 40.29 (1.4.94)" — Version command will not find it.
timestamp: 2026-10-10T18:00:00Z
---

# ID string lacks `$VER:` prefix

RomTag RT_IDSTRING = `"freeanim 40.29 (1.4.94)\r\n"` — no `$VER:`
prefix, so the Version command cannot report it.  The other build in
this set, 40.9, uses `"freeanim.library 40.9 (11.8.95)"` — also
without `$VER:`.  Compare _asl 40.6 and fwfiltertype 3.0, which do
carry the prefix.
