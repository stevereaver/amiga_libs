---
type: Finding
title: Dead ln_Type write at offset 0x0c
description: First InitStruct entry writes byte 9 at offset 12, inside ln_Name.
timestamp: 2026-10-10T19:00:00Z
---

# Dead ln_Type write at offset 0x0c

The first InitStruct entry is `INITBYTE offset 0x000c = 0x09` —
offset 12 is inside the `ln_Name` pointer (bytes 10-13).  The very
next entry (`INITLONG offset 0x000a = _libname`) overwrites all four
bytes, so the write is dead.  Every later build writes `ln_Type` at
offset 8 as expected.

This may reflect a Kickstart 1.1-era initializer quirk or a source
bug in the original ("mylib") build; either way `ln_Type` still ends
up 0 because the field is never otherwise set — the library node is
never scanned by type before being added, and `AddLibrary` fixes
nothing, yet `FindName`-style lookups do not check ln_Type, so the
omission is survivable.  Open question: whether Kickstart 1.1's
InitStruct base differed, which would make offset 12 land at
ln_Type+4.  Reproduced verbatim in `version_lib.s`.
