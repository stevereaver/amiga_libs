---
type: Finding
title: 24-bit InitStruct encoding
description: InitStruct commands use the 24-bit offset form for sub-256 offsets.
timestamp: 2026-10-10T19:00:00Z
---

# 24-bit InitStruct encoding

Every entry in this build's InitStruct data uses the long-offset
command form (0xc0/0xd0/0xe0 + 16-bit offset) even though all offsets
are < 256 and the compact 0x80/0x90/0xa0 + byte-offset form would
work.  An early `initializers.i` always emitted the 24-bit form;
34.34 (WB1.3.3) and later builds switched to the compact encoding.
