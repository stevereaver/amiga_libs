---
type: Index
title: Findings
description: Quirks, open questions, and version differences for this library.
---

# Findings

- [UninitializedOpener](UninitializedOpener.md) — the OpenLibrary pointer at +0x22 is never set
- [FailPathBug](FailPathBug.md) — failed open still calls CloseLibrary on the exec base
- [InitStructQuirk](InitStructQuirk.md) — `INITBYTE(0x0c,9)` writes into the ln_Name pointer
- [Naming](Naming.md) — `_asl.` directory/`_asl.library` name vs `asl_lib.fd`
