---
type: Library
title: bsdsocket.library 9.0
description: >-
  BSD sockets front-end library: 48 vectors marshaling tagged
  wire messages to an internal TCP/IP engine object (semaphore-
  bracketed transactions).  Canonical bsdsocket_lib.fd naming.
timestamp: 2026-10-15T10:00:00Z
---

# bsdsocket.library 9.0

Socket API proxy: the library itself holds no TCP/IP state - it
packs each request into a shared message block with a 1-byte opcode
and hands it to an engine object stored at base+0x26 (which is
itself called through -564/-570 bracket vectors = obtain/release).

## Binary facts

- 6652 bytes; 3 hunks (CODE 0x1514 + DATA 0x1c0 + BSS 0x25c)
- RomTag AUTOINIT v9; InitTable datasize 0xf6
- functab: 52 entries; 48 user slots; several alias shared stubs
  (return -1 x3, return 0 x3)

## Wire protocol (partially decoded opcodes)

| op | call | | op | call |
|----|------|-|----|------|
| 0x4b | socket | | 0x54 | shutdown |
| 0x4e | bind   | | 0x49 | setsockopt-ish |
| 0x4c | listen | | 0x58 | WaitSelect-ish |
| 0x41 | accept | | 0x57 | getsockname-ish |
| 0x4f | connect/sendto | | 0x2e | close/hostent pair |
| 0x53 | send   | | 0x52 | servent pair |
| 0x46 | recvfrom | | 0x10,0x20 | misc |

## Status

FULL - all 48 LVOs mapped + named (canonical fd order); C model
ports the marshal/dispatch skeleton faithfully; per-opcode arg
layouts partially decoded (see findings).

## Contents

- [functions/](functions/index.md) - [structures/](structures/index.md)
- [findings/](findings/index.md) - [algorithms/](algorithms/index.md) - [log.md](log.md)
