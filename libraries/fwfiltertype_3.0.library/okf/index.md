---
type: Library
title: fwfiltertype.library 3.0
description: >-
  Tiny SoftWood AUTOINIT library ($VER: fwfiltertype.library 3.0 (6.8.93),
  556 bytes, single code hunk). Standard skeleton plus one user function,
  FwFilterType, which maps a type field matching "alph" to the string
  "fwpha".
tags: [softwood, autoinit, stub]
timestamp: 2026-10-10T19:15:00Z
---

# fwfiltertype.library 3.0 — Knowledge Bundle

`binary/fwfiltertype_3.0.library` — sha256
`6c2b7f6d093b72a6c23318d6ef4c5a8f2c5071c7f0c51e32e942125d911e16b7`, 556
bytes, one code hunk (0x1b4 bytes code, 17 RELOC32 entries). Copyright
string: "Copyright © 1993 SoftWood, Inc."

## Status

Fully reconstructed in C. `source/` builds with m68k-amigaos-gcc 16.2 into
a single-hunk `.library` whose RomTag, name/id strings, InitTable
(dataSize 0x28), InitStruct bytes and six-entry absolute-long vector
table match the original layout field-for-field. Code differs only in
gcc codegen.

## Contents

- [functions/](functions/index.md) — all 6 LVO entries (-6 .. -36)
- [structures/](structures/index.md) — FWFilterBase, InitTable, hunk map
- [findings/](findings/index.md) — quirks and open questions
- [log.md](log.md) — work journal

## Notes

- Only one user LVO exists: `FwFilterType` at -30; -36 is a second
  reserved null slot sharing the same stub as -24.
- No NDK `*_lib.fd` exists for this library; the name/LVO assignment is
  derived from the binary alone.
