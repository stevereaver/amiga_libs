---
type: Library
title: _asl.library 40.6
description: AUTOINIT proxy library — relays LVOs -30..-60 to the real asl.library v36.
tags: [proxy, autoinit]
---

# _asl.library 40.6 — Knowledge Bundle

## Overview

Binary: `binary/_asl._40.6.library`, 452 bytes,
SHA256 `3537e265db6d795f2058ba94f1c6b3f237215da7a30f349de4de6bb246c46e64`.
ID string `$VER: _asl.library 40.6`.

Single code hunk, RomTag `RTF_AUTOINIT`, version 40, NT_LIBRARY,
priority 0.  The public vectors -30..-60 are six small stubs that
open the real `"asl.library"` v36 through a function pointer kept at
libbase+0x22, `jsr` the same LVO on the real base, close the library
and return the result — a per-call open/call/close relay.

Function names resolved via NDK `asl_lib.fd` (AllocFileRequest,
FreeFileRequest, RequestFile, AllocAslRequest, FreeAslRequest,
AslRequest).  The directory name uses `_asl.`/`_asl.` rather than
the conventional `asl_` prefix.

Reconstructed byte-identically in `source/_asl.s` (asm; MD5
`7aac04fa4d5acb542565cf8f60faa68c`); the earlier multi-file model
(`asl.c`, `asl_lib.s`, `asl_relay.s`, `datatab.s`, two-pass
`functab`) is kept as semantic documentation via `make cmodel`.
Runtime oracle `work/oracle.py` verifies identical behaviour under
machine68k.

## Categories

- [functions/](functions/index.md) — LVO entries
- [structures/](structures/index.md) — hunk map, RomTag/InitTable, base layout
- [findings/](findings/index.md) — quirks, bugs and open questions
- [log.md](log.md) — work journal
