---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2026-10-10

- Parsed hunk: single code hunk 0x164 bytes, 0x0b relocs.
- RomTag AUTOINIT v40; EndSkip = hunk end.
- Function table: 10 word-offset entries → Open/Close/Expunge/
  -24 stub/six relay stubs; extra -1 pad word before datatable.
- Identified shim semantics: relays to real asl.library v36 through
  libbase+0x22 fnptr (never initialised — bug preserved); failure
  path calls CloseLibrary on exec base (bug preserved).
- Function names resolved via NDK asl_lib.fd (-30..-60).
- Reconstruction: header .s, InitStruct datatab.s (incl. a00c quirk),
  C lifecycle, asl_relay.s relay stubs, two-pass functab.
  `make` → valid HUNK library; table layout lands on identical
  offsets.
