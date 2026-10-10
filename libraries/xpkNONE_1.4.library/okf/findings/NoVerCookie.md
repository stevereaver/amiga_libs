---
type: Finding
title: IdString has no "$VER:" cookie
timestamp: 2026-10-10T19:45:00Z
---

# No $VER: cookie

`lib_IdString` and `rt_IDString` point at
`"xpkNONE 1.4 (19.07.1998)\r\n"` — a plain banner with **no `$VER:`
cookie**. The standard `Version` command and any `$VER:` scanner
therefore cannot identify this library version.

The sister build `xpkNONE_1.5(000)` (Dirk Stöcker, 2013) carries a
proper `"$VER: xpkNONE V1.5 (1 Oct 2013) by Dirk Stoecker"` string —
the cookie was added in the later rebuild.
