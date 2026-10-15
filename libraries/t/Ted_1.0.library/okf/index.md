---
type: Library
title: ted.library 1.0 (28.12.95)
description: >-
  Shared-variable / method-dispatch shim: five code-hunk global
  pointers are set/read through trivial vectors; global 3 anchors
  an external structure whose offsets 12 and 100..116 are used as
  a method/string pointer table.
timestamp: 2026-10-10T20:20:00Z
---

# ted.library 1.0 (28.12.95)

Single-hunk library that exposes five longword global pointers and
a set of getters/indirect calls over them.  It opens
`dos.library` (v0) at init but never uses it — likely a stub
dependency.  The real purpose is a shared "context pointer"
(global 3) into an external structure: offsets +12 and +100 are
callable methods, +104/+108 string pointers, +112/+116 pointers
whose target's -2 longword is returned.

## Binary facts

- sha256 `6e3c74b3fcc53ad9fac52cf26b041013f96367c012d15deb994450402398019e`, 1116 bytes
- hunks: single CODE hunk 0x364 bytes
- RomTag: RTF_AUTOINIT, version 1, NT_LIBRARY, pri 0
- idstring: `ted 1.0 (28.12.95)\r\n`
- InitTable dataSize 0x30, InitStruct data (version 1/revision 0)
- absolute-longword functable: 20 vectors + -1L
- module entry returns -1; dos.library opened but never used
- private DELEXP-style flag at base+34 (bit 3), not lib_Flags
- globals and a ~255-byte scratch buffer live inside the code hunk

## Status

Reconstructed entirely in assembly (`source/ted_lib.s`) to keep
the code-hunk globals and scratch buffer addressed the same way.
`make` builds a valid `ted.library`.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
