---
type: Finding
title: Uninitialised OpenLibrary pointer
description: The relay tail calls a function pointer at libbase+0x22 that no code in the library ever sets.
timestamp: 2026-10-10T18:00:00Z
---

# Uninitialised OpenLibrary pointer

The relay tail does `movea.l 34(a6),a0 / jsr (a0)` expecting a
function with OpenLibrary's signature (name=a1, version=d0 → d0).
But no store to +0x22 exists anywhere in the binary — the InitStruct
covers 0x0a..0x18 and 0x26, init only writes 0x2a.

Consequence: a freshly-loaded _asl.library jumps to address 0 on any
public call.  The only consistent interpretation is that a host
program (whichever binary ships this lib) pokes a routine pointer
into the field after opening — probably &exec's OpenLibrary or a
wrapper — making `_asl.library` a thin redirector that lets an
application call asl functions through a private lib name.

Reconstruction preserves this behaviour exactly.
