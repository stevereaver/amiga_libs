---
type: Library
title: GhostRider 37.2
description: >-
  Hotkey input-event interceptor library for the GhostRider
  launcher; installs an input.device handler that swallows the
  event chain and fires launcher-registered callbacks.
timestamp: 2026-10-11T01:55:00Z
---

# GhostRider 37.2

Companion library for the "GhostRider" launcher ("Setup GhostRider
Launcher" appears as a node name in the binary).  GRArm (LVO -36)
installs a priority-64 struct Interrupt input handler via
input.device `IND_ADDHANDLER`; the handler walks the InputEvent
chain and, on a configured hotkey (keycode + qualifier mask) or
mouse-button pattern, clears/re-raises the PORTS interrupt and
invokes a launcher-registered function through a private
`{UWORD key, LONG (*fn)()}` table reached by abusing
`FindPort("GhostRider.Port")`'s `port+0x22` longword.

## Binary facts

- sha256 757a4c23052a8154754eaa078ebb7f5fe34bf330d0a94298f65d8083099a1086
- 1184 bytes, single code hunk (1052 bytes)
- entry stub `moveq #20,d0 / rts` (returns 20 when executed)
- RomTag at hunk+4: RTF_AUTOINIT, version 37, NT_LIBRARY, pri 0
- InitTable dataSize 0x2a (bare library + seglist + SysBase)
- absolute-longword function table, 8 vectors, two -1 longs
- InitStruct: ln_Type NT_LIBRARY, ln_Name, lib_Flags 6
  (LIBF_SUMUSED|LIBF_CHANGED), lib_Version 37, lib_Revision 2,
  lib_IdString
- idstring `GhostRider.library 37.2 (3 Aug 1994)\r\n`
- state block (Interrupt + IOStdReq + MsgPort + trigger config)
  embedded in the code hunk at +0x338
- strings: `input.device`, `GhostRider.Port`,
  `Setup GhostRider Launcher` (used as both the reply-port node
  name and the Interrupt name's intended target)

## Public API (LVOs)

| LVO | name | behavior |
|-----|------|----------|
| -6  | LibOpen   | open count++, clear LIBF_DELEXP, return base |
| -12 | LibClose  | open count--, **always returns 0** (never expunges) |
| -18 | LibExpunge| DELEXP or Remove+FreeMem, return seglist |
| -24 | LibNull   | return 0 |
| -30 | GRDispatch| invoke launcher table key 0 with d0=arg, return arg |
| -36 | GRArm     | d0!=0: store mode/key/qual, IND_ADDHANDLER; d0==0: IND_REMHANDLER |
| -42 | GRCall6   | invoke table key 6 under Disable/VBR-write/CacheClearU/Enable, return fn d0 or -2 |
| -48 | GRCall7   | same for key 7, also preserves fn's d1 |

## Status

FULL - reconstructed C source builds a valid hunk library
(m68k-amigaos-gcc -m68000).  All Exec LVOs resolved (-30
Supervisor, -120 Disable, -126 Enable, -210 FreeMem, -252 Remove,
-294 FindTask, -354 AddPort, -360 RemPort, -390 FindPort, -444
OpenDevice, -450 CloseDevice, -456 DoIO, -636 CacheClearU).
Compiled code verified vector-by-vector against the shipped
disassembly.  Cannot be functionally exercised without a live
Exec + input.device + a peer "GhostRider.Port" launcher task.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [algorithms/](algorithms/index.md)
- [findings/](findings/index.md)
