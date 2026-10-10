---
type: Library
title: warpHW.library 1.0 "WarpUp hardware driver for BlizzardPPC"
description: >-
  warpHW.library 1.0 (10-Apr-98) -- a BlizzardPPC hardware
  driver for the WarpUp PPC kernel.  A hybrid 68k+PowerPC
  library: the 68k side walks SysBase for the PPC address
  window and pokes CSPPC control registers at $00f6xxxx,
  and it embeds a small PowerPC routine a PPC task can
  call.  Original is a SAS/C far-data three-hunk build.
timestamp: 2026-10-28T00:00:00Z
---

# warpHW.library 1.0

"WarpUp hardware driver for BlizzardPPC" — the 68k-side
companion to the WarpUp PowerPC kernel.  It maps/controls
the Phase5 Blizzard PPC card through the CSPPC register
window at `$00f6xxxx`, exposes a memory-window finder, and
carries a fragment of native PowerPC code.

## Binary facts

- 1392 bytes, THREE hunks (2 CODE + 1 DATA), SAS/C far-data
- sha256: `cf5d7a5ac5692aab182cc1f0394980bb90576e73eb103ca94ff1ffbea6d9e5c7`
- RomTag: RTF_AUTOINIT, ver 1, NT_LIBRARY, dataSize 0x22
- FUNCTABLE = 10 LONG-address vectors + `0xffffffff`,
  living in the DATA hunk (cross-hunk reloc)
- strings: "warpHW.library",
  "$VER: warpHW.library 1.0 (10-Apr-98)",
  "WarpUp hardware driver for BlizzardPPC"

## Public vectors / LVOs

| LVO | name        | semantics                                    |
|-----|-------------|----------------------------------------------|
|  -6 | Open        | opencnt++/clr-DELEXP                          |
| -12 | Close       | opencnt--/delayed expunge                     |
| -18 | Expunge     | Remove+FreeMem, return seglist                |
| -24 | Reserved    | -> entry stub                                 |
| -30 | whwDesc     | return driver-descriptor pointer              |
| -36 | whwVer      | returns 1                                     |
| -42 | whwFindIO   | walk list @SysBase+322, return [24] of node   |
|     |             | with [20]>=0x40000000,[24]<0x80000000         |
| -48 | whwPoke3    | BlizzardPPC register-write sequence           |
| -54 | whwPoke4    | write $01 to $f60038                          |
| -60 | whwPPC      | pointer to the embedded PPC routine           |

## BlizzardPPC register writes (-48)

`MOVE.B #imm,(A0)` to the `$f6xxxx` CSPPC space, with
`NOP;RTS` settle delays:
`f60000=0x10`, `f60028=0x82`, `f60038=0xff`,
`f60030=0x87`, `f60008=0xa8`, `f60008=0x10`,
`f60000=0x90`, `f60028=0x02`, `f60030=0x40`.

## Embedded PowerPC code (-60)

The library embeds a small PPC routine (big-endian
opcodes: `mflr`/`stwu`/`lis r11,0xf6`/`stb`/`blr`) that
pokes a `$f6` register from the PPC side — used by WarpUp
to drive the card once the PPC is running.

## Reconstruction

Functional reconstruction (single CODE hunk): framework +
all six functions; the register pokes and the PPC blob are
reproduced exactly, the SysBase+322 list walk and the
descriptor layout faithfully.  NOT byte-identical to the
original's three-hunk far-data layout.
