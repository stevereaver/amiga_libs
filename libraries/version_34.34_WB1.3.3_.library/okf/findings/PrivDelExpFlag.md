---
type: Finding
title: Private deferred-expunge flag
description: Bit 3 of a private byte at base+42, not lib_Flags.
timestamp: 2026-10-10T19:00:00Z
---

# Private deferred-expunge flag

`LIBF_DELEXP` semantics are implemented on bit 3 of a private byte at
base+0x2a, not on `lib_Flags` at offset 14.  `lib_Flags` itself is
initialized to 6 (LIBF_SUMUSED|LIBF_CHANGED) and never touched by
Open/Close/Expunge.
