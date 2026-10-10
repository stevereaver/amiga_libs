---
type: Structure
title: DspExtSym
description: Caller's external symbol table (v1.1 form).
resource: source/dspbase.h
timestamp: 2026-10-10T20:10:00Z
---

# DspExtSym

The third [DSPRelocate](../functions/DSPRelocate.md) argument in this
build: a plain array of 8-byte `{name,value}` pairs, terminated by a
NULL name — **not** the `DSP3210GlobSymHeader` struct of the v7 API.

```c
struct DspExtSym { const char *ds_Name; ULONG ds_Value; };
```

Lookup is a linear scan with byte-compare (`cmpm`); on a match the
relocation uses `ds_Value` directly (no section adjustment).
