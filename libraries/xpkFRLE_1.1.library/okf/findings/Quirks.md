---
type: Finding
title: Quirks
description: Oddities that are intentional or harmless.
timestamp: 2026-10-10T22:45:00Z
---

# Quirks

- **Module entry returns -1**, not 0 — the standard `moveq`
  stub is #-1 here; the separate null stub for ExtFunc etc. is
  `moveq #0,d0`.
- **No `$VER:` cookie** in the idstring (`xpkFRLE v1.1\r\n`) —
  AmigaOS version scanners find nothing.
- **No stream terminator** — unlike xpkRLEN (0x00 terminator),
  FRLE decode stops purely on InLen exhaustion; a byte
  appended/dropped silently corrupts or truncates output.
- **"Cache-optimized"** is the descriptor's claim; the actual
  encoder is an unrolled pair-scanner, and the XOR headers cost
  the decoder two extra ops per run vs ByteRun.
- **xi_Ratio = 2 (2%)** — aspirational; there is no expansion
  bail-out so incompressible chunks grow slightly.
- dataSize 0x26 has no SysBase slot — Expunge reloads SysBase
  from `4.w` (fine on an Amiga, worth noting for emulation).
