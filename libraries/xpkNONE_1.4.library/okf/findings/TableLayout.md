---
type: Finding
title: Function table precedes the RomTag
timestamp: 2026-10-10T19:45:00Z
---

# Nonstandard table layout

The code hunk opens with the function table at +0x04, then padding,
then the InitStruct data (+0x54), InitTable (+0x74) and only then the
RomTag (+0x84). Most AUTOINIT libraries put the RomTag at +4 and the
tables after it.

Legal either way — the resident scanner locates the tag by its
`4afc` matchword anywhere in the loaded segment — but unusual enough
to suggest this binary was hand-assembled or built with a custom
linker script rather than the usual startup module.
