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
- **Reserved vectors share the deferred-expunge tail.**  The
  four dead slots (-24/-42/-48/-60) all point at hunk 0x1b8 —
  the `moveq #0,d0; rts` that is also the fall-through after
  `bset #3` on the deferred-expunge path.
- **functab physically precedes datatab** (0x2e vs 0x46); all
  code sits after the XpkInfo/XpkMode islands and strings.
- **Expunge is stack-framed, not register-framed**: pushes
  seglist and libbase on the stack around Remove/FreeMem
  (`move.l a6,-(a7)` ... `movea.l (a7)+,a6`), restoring a6 —
  unlike siblings that use moveml.
- **Decoder constant asymmetry**: repeat count uses a +0x20
  bias (`sub.b #0x20`), literal count +0x1f — encoding n-2 vs
  len-1 respectively; both emitted with noncanonical
  AND.B/SUB.B-with-immediate-ea opcodes (`c23c`/`923c`).
- **`eor.b d2,d5` in the tail-literal emit** XORs into the
  key register instead of the count — writes `(len-1)^0x1f`
  but leaves d5 corrupted; harmless, the routine returns
  immediately after.
- **Asymmetric OutLen store**: pack uses `suba.l -8(a0),a3;
  move.l a3,(a0)` (a0 already at pb+0x10); unpack uses the
  predecrement trick `suba.l -(a0),a3; move.l a3,8(a0)`.
- **Pack bound is OutBuf+OutBufLen** (xsp_OutBufLen honoured,
  overflow -> -17) while unpack has no output bound at all.
- **RELOC32 tail is descending** — 18 sites listed
  back-to-front; the GNU toolchain emits ascending, so the
  Makefile rewrites the table with fixup.py.
