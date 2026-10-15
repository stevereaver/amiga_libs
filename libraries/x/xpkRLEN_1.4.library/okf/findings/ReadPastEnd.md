---
type: Finding
title: Reads past the input end
description: The run detector samples src[1] and src[2] unconditionally.
timestamp: 2026-10-10T09:40:00Z
---

# Reads past the input end

Each encoder iteration loads `(1,a1)` and — if equal — `(2,a1)`
before checking `src == srcend`. For the last input byte (and a
zero-length input) these read 1–2 bytes past `InBuf + InLen`. Benign
on flat 68k memory (the bytes are only used for a run test that a
following `src==srcend` check cancels), but it's an out-of-bounds
read — worth knowing before fuzzing or relocating buffers.
