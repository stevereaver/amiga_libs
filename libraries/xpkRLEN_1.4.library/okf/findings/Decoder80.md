---
type: Finding
title: Code 0x80 decodes to nothing
description: neg.b on -128 leaves a negative count; zero bytes emitted.
timestamp: 2026-10-10T09:40:00Z
---

# Code 0x80 decodes to nothing

The decoder treats `code<0` as "repeat the next byte `-code` times".
For code 0x80, `neg.b` produces -128 again (overflow stays negative),
the `ble` test skips the emit loop, and the repeat byte is consumed
but produces no output. So 0x80 is a legal-but-useless "consume one
input byte" escape — the encoder never generates it.
