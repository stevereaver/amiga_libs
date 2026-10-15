---
type: Library
title: toshstart.library 1.0 - Kevin McIntosh machine-support lib
description: >-
  Bespoke machine-support library: opens dos/graphics/intuition,
  wraps DOS internal vectors (-30/-60/-84 packet dispatch), device
  IORequest SendIO/CheckIO/AbortIO+WaitIO, tick polling, charset
  lookup, hex/decimal formatters, tokenizer. 22 user LVOs.
timestamp: 2026-10-15T09:00:00Z
---

# toshstart.library 1.0

Kevin McIntosh's machine-support library ("PVER: Toshstart.Library
Ver 1.0").  Opens `dos.library`, `intuition.library`,
`graphics.library` at init; private globals live in a zeroed pool
inside the code hunk (Aztec small-data).

## Binary facts

- 6488 bytes; single CODE hunk 0x14b4; RomTag AUTOINIT v1
- 22 user vectors (-30..-156); absolute-longword functab
- init: OldOpenLibrary x3 with reverse-order unwind on failure
- touches CIA/dma registers (CIAA_SDR, DMACON, COP1LCH) and makes
  device IORequests (cmd 0x25) - hardware-facing

## API map (reconstructed names)

| LVO | Symbol | Behavior |
|-----|--------|----------|
| -30 | ToshFunc0 | stash args; call dos -60 packet vector |
| -36 | ToshFunc1 | DMACON set + internal passes |
| -42 | ToshFunc2 | flag-set + gfx -228 call |
| -48 | ToshFunc3 | flag-clear + gfx -228 call |
| -54 | ToshFunc4 | busy-wait on tick word change |
| -60 | ToshFunc5 | wait d0+1 ticks |
| -66 | ToshFunc6 | prime IORequest(0x25)+SendIO |
| -72 | ToshFunc7 | CheckIO else AbortIO+WaitIO |
| -78 | ToshFunc8 | ToshFunc7 + stash arg |
| -84 | ToshFunc9 | clear flag + dos -60 call |
| -90 | ToshFunc10 | dos -84 internal call |
| -96 | ToshFunc11 | dos -30 (code 0x3ed) |
| -102| ToshFunc12 | dos -30 (code 0x3ee) |
| -108| ToshFunc13 | mode-2 dispatch via internal |
| -114| ToshFunc14 | mode-3 dispatch via internal |
| -120| ToshFunc15 | charset index lookup |
| -126| ToshFunc16 | returns &DOSBase slot |
| -132| ToshFunc17 | decimal formatter |
| -138| ToshFunc18 | hex formatter ('$' prefix) |
| -144| ToshFunc19 | tokenizer (skip ' ','\n',NUL) |
| -150| ToshFunc20 | set callback ptr |
| -156| ToshFunc21 | clear 18B scratch + state |

## Status

FULL - source/ builds a valid AUTOINIT library; all 22 LVOs
identified and documented.  Not byte-identical (semantics port).

## Contents

- [functions/](functions/index.md) - [structures/](structures/index.md)
- [findings/](findings/index.md) - [log.md](log.md)
