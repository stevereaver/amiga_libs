---
type: Finding
title: RebuildDeviations
description: Where the reconstruction differs from the shipped binary.
timestamp: 2026-10-10T20:40:00Z
---

# Rebuild deviations

- Code hunk differs in size/layout (GCC codegen); all call
  sequences verified (OpenLibrary order, lowlevel -36,
  locale -156/-42, dos -30/-48/-42/-36, graphics -222/-270/-288/
  -582).
- The prompt is written with dos `Write` (94 bytes) as in the
  original; the read loop uses dos `Read` 1 byte at a time.
- Function names are reconstructed — no fd ships with the binary.
