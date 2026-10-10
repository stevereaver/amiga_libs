---
type: Finding
title: lib_IdString points inside the "$VER:" string
timestamp: 2026-10-10T19:15:00Z
---

# IdString offset

The InitStruct `lib_IdString` value is .text+0x39 — the 'f' of
"fwfiltertype.library" *inside* the `$VER:` string, i.e. the field reads
`"fwfiltertype.library 3.0 (6.8.93)\n"`. The `$VER: ` cookie sits
immediately before it, so the OS version scanner still finds a normal
`$VER:` sequence in memory.

Same arrangement as the 680x0.library dispatchers
(../../680x0_40.4.library/okf/index.md), where lib_IdString also skips
the cookie. Reproduced in the reconstruction by emitting the `$VER: `
prefix as separate bytes before the `_idstr` label.
