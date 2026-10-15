---
type: Library
title: mhimasstd.library 1.5 (26.08.2022)
description: >-
  MHI audio driver for the parallel-port "MAS Player Pro"
  (MAS3507-class MP3 decoder on CIA-B).  Standard 10-function MHI
  API; claims misc.resource parallel-port units, 64KB ring buffer.
timestamp: 2026-10-15T09:30:00Z
---

# mhimasstd.library 1.5

MHI (MASI) driver feeding a parallel-port MAS decoder chip.  Three
hunks: CODE (strings + code), DATA (RomTag + InitStruct +
InitTable + functab + CIA base addrs), BSS (DOSBase/GFXBase/
MiscBase/owner/list).

## Binary facts

- 6584 bytes; SAS/C build (link/unlk + jsr(pc) stubs)
- RomTag AUTOINIT v1 r5, embedded in the DATA hunk
- CIA regs: CIAA_PRA/PRB/DDRB + CIAB_PRA/DDRA baked as `.data`
  constants ($bfe001/$bfd000)

## API - standard MHI

| LVO | Function | Behavior |
|-----|----------|----------|
| -30 | MHIAllocDecoder | gfx open + 64KB handle + misc.resource parallel claim |
| -36 | MHIFreeDecoder  | free ring, drain BufList, release units, close gfx |
| -42 | MHIQueueBuffer  | queue 20-byte node on _BufList |
| -48 | MHIGetEmpty     | RemHead consumed buffer |
| -54 | MHIGetStatus    | copy 25-byte status out |
| -60 | MHIPlay         | CIA-B strobe start |
| -66 | MHIStop         | release |
| -72 | MHIPause        | deassert |
| -78 | MHIQuery        | capability mask |
| -84 | MHISetParam     | set param byte (0-5) |

## Status

FULL - source/ builds a valid 3-hunk library; all LVOs resolved;
C model ports the decoded semantics.

## Contents

- [functions/](functions/index.md) - [structures/](structures/index.md)
- [findings/](findings/index.md) - [log.md](log.md)
